defmodule RubensBankingApi do
  @moduledoc """
  RubensBankingApi keeps the contexts that define your domain
  and business logic.

  Responsible for all operations. Uses Multi so that operations only
  happen in case all operations are successful, in order to avoid
  tables being different.
  """

  require Logger

  alias RubensBankingApi.Accounts
  alias RubensBankingApi.AccountTransactions
  alias RubensBankingApi.Repo

  defdelegate get_account(id), to: Accounts
  defdelegate get_report(report_params), to: AccountTransactions

  alias RubensBankingApi.Helpers.MoneyHelper

  alias Ecto.Multi

  def create_new_account(
        %{"document" => _document, "document_type" => _document_type, "owner_name" => _owner_name} =
          params
      ) do
    Multi.new()
    |> Multi.run(:generate_new_account_params, fn _changes ->
      new_account_params = params |> Map.put("status", "open") |> Map.put("balance", 100_000)

      {:ok, new_account_params}
    end)
    |> Multi.run(:create_account, fn %{generate_new_account_params: new_account_params} ->
      Accounts.create_account(new_account_params)
    end)
    |> Multi.run(:generate_account_transaction_params, fn %{
                                                            create_account: %{
                                                              account_code: account_code,
                                                              balance: amount
                                                            }
                                                          } ->
      {:ok,
       %{
         transaction_starter_account_code: account_code,
         amount: amount,
         transaction_type: "open account"
       }}
    end)
    |> Multi.run(:create_account_transaction, fn %{
                                                   generate_account_transaction_params:
                                                     account_transaction_params
                                                 } ->
      AccountTransactions.create_account_transaction(account_transaction_params)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_account: account}} ->
        Logger.info("Successfully created account")
        {:ok, account}

      {:error, operation_identifier, reason, _changes} ->
        Logger.error("Failed to create account in #{operation_identifier}",
          error: inspect(reason)
        )

        {:error, reason}
    end
  end

  def create_new_account(_params) do
    Logger.error("Failed to create account due to missing parameters")
    {:error, :missing_parameters}
  end

  def transfer_money(%{
        "transaction_starter_account_code" => transaction_starter_account_code,
        "receiver_account_code" => receiver_account_code,
        "amount" => amount
      }) do
    Multi.new()
    |> Multi.run(:check_amount, fn _changes ->
      case Integer.parse(amount) do
        :error ->
          Logger.error("Failed to transfer money due to amount not being an integer")
          {:error, :amount_is_not_integer}

        {amount, _base} ->
          {:ok, amount}
      end
    end)
    |> Multi.run(:get_transaction_starter_account, fn _changes ->
      Accounts.get_account(transaction_starter_account_code)
    end)
    |> Multi.run(:get_receiver_account, fn _changes ->
      Accounts.get_account(receiver_account_code)
    end)
    |> Multi.run(:update_transaction_starter_balance, fn %{
                                                           get_transaction_starter_account:
                                                             %{balance: balance} = account,
                                                           check_amount: amount
                                                         } ->
      Accounts.update_account_balance(account, %{balance: balance - amount})
    end)
    |> Multi.run(:update_receiver_balance, fn %{
                                                get_receiver_account:
                                                  %{balance: balance} = account,
                                                check_amount: amount
                                              } ->
      Accounts.update_account_balance(account, %{balance: balance + amount})
    end)
    |> Multi.run(:generate_account_transaction_params, fn %{
                                                            get_transaction_starter_account: %{
                                                              account_code:
                                                                transaction_starter_account_code
                                                            },
                                                            get_receiver_account: %{
                                                              account_code: receiver_account_code
                                                            }
                                                          } ->
      {:ok,
       %{
         transaction_starter_account_code: transaction_starter_account_code,
         receiver_account_code: receiver_account_code,
         amount: amount,
         transaction_type: "transfer money"
       }}
    end)
    |> Multi.run(:create_transfer_money_account_transaction, fn %{
                                                                  generate_account_transaction_params:
                                                                    account_transaction_params
                                                                } ->
      AccountTransactions.create_account_transaction(account_transaction_params)
    end)
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         create_transfer_money_account_transaction: account_transaction,
         get_transaction_starter_account: %{owner_name: transaction_starter_owner_name},
         get_receiver_account: %{owner_name: receiver_owner_name}
       }} ->
        Logger.info(
          "Successfully transfered #{MoneyHelper.convert_amount(amount)} from #{
            transaction_starter_owner_name
          }'s account to #{receiver_owner_name}'s account"
        )

        {:ok, account_transaction}

      {:error, operation_identifier, reason, _changes} ->
        Logger.error("Failed to transfer money in #{operation_identifier}",
          error: inspect(reason)
        )

        {:error, reason}
    end
  end

  def transfer_money(_params) do
    Logger.error("Failed to transfer money due to missing parameters")
    {:error, :missing_parameters}
  end

  def withdraw(%{"account_code" => account_code, "amount" => amount}) do
    Multi.new()
    |> Multi.run(:check_amount, fn _changes ->
      case Integer.parse(amount) do
        :error ->
          Logger.error("Failed to withdraw due to amount not being an integer")
          {:error, :amount_is_not_integer}

        {amount, _base} ->
          {:ok, amount}
      end
    end)
    |> Multi.run(:get_account, fn _changes ->
      Accounts.get_account(account_code)
    end)
    |> Multi.run(:update_account, fn %{
                                       get_account: %{balance: balance} = account,
                                       check_amount: amount
                                     } ->
      Accounts.update_account_balance(account, %{balance: balance - amount})
    end)
    |> Multi.run(:notify_account_owner, fn %{check_amount: amount} ->
      Logger.info(
        "Successfully sent email to account owner notifying the withdraw of #{
          MoneyHelper.convert_amount(amount)
        }"
      )

      {:ok, :ok}
    end)
    |> Multi.run(:generate_account_transaction_params, fn %{
                                                            get_account: %{
                                                              account_code:
                                                                transaction_starter_account_code
                                                            }
                                                          } ->
      {:ok,
       %{
         transaction_starter_account_code: transaction_starter_account_code,
         amount: amount,
         transaction_type: "withdraw"
       }}
    end)
    |> Multi.run(:create_withdraw_account_transaction, fn %{
                                                            generate_account_transaction_params:
                                                              account_transaction_params
                                                          } ->
      AccountTransactions.create_account_transaction(account_transaction_params)
    end)
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         update_account: %{owner_name: account_owner_name} = account
       }} ->
        Logger.info(
          "Successfully withdrew #{MoneyHelper.convert_amount(amount)} from #{account_owner_name}'s account"
        )

        {:ok, account}

      {:error, operation_identifier, reason, _changes} ->
        Logger.error("Failed to withdraw in #{operation_identifier}",
          error: inspect(reason)
        )

        {:error, reason}
    end
  end

  def withdraw(_params) do
    Logger.error("Failed to withdraw due to missing parameters")
    {:error, :missing_parameters}
  end

  def close_account(%{"account_code" => account_code}) do
    Multi.new()
    |> Multi.run(:get_account, fn _changes ->
      Accounts.get_account(account_code)
    end)
    |> Multi.run(:close_account, fn %{get_account: account} ->
      Accounts.close_account(account)
    end)
    |> Multi.run(:generate_account_transaction_params, fn %{
                                                            get_account: %{
                                                              account_code: account_code
                                                            }
                                                          } ->
      {:ok, %{transaction_starter_account_code: account_code, transaction_type: "close account"}}
    end)
    |> Multi.run(:create_close_account_account_transaction, fn %{
                                                                 generate_account_transaction_params:
                                                                   account_transaction_params
                                                               } ->
      AccountTransactions.create_account_transaction(account_transaction_params)
    end)
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         close_account: account
       }} ->
        Logger.info("Successfully closed #{account.owner_name}'s account")

        {:ok, account}

      {:error, operation_identifier, reason, _changes} ->
        Logger.error("Failed to close account in #{operation_identifier}",
          error: inspect(reason)
        )

        {:error, reason}
    end
  end

  def close_account(_params) do
    Logger.error("Failed to close account due to missing parameters")
    {:error, :missing_parameters}
  end
end
