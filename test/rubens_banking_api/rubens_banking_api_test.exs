defmodule RubensBankingApiTest do
  use RubensBankingApi.DataCase, async: false

  alias RubensBankingApi.Accounts.{Account, AccountsRepository}
  alias RubensBankingApi.AccountTransactions.{AccountTransaction, AccountTransactionsRepository}

  alias RubensBankingApi.Helpers.AccountHelper

  import ExUnit.CaptureLog

  setup do
    log_level = Application.get_env(:logger, :level)

    Logger.configure(level: :debug)

    on_exit(fn ->
      Logger.configure(level: log_level)
    end)
  end

  describe "create_new_account/1" do
    @moduletag :capture_log
    test "successfully creates a new account and a transaction" do
      params = %{"document" => "9878978973", "document_type" => "CPF", "owner_name" => "Kendrick"}

      assert Enum.empty?(AccountsRepository.get_all())

      assert {:ok,
              %Account{
                account_code: account_code,
                balance: amount
              }} = RubensBankingApi.create_new_account(params)

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "open account",
                  amount: ^amount
                }
              ]} = AccountTransactionsRepository.generate_report(account_code, :total)
    end

    test "returns error when create_account fails" do
      params = %{"document" => nil, "document_type" => nil, "owner_name" => nil}

      assert capture_log([level: :error], fn ->
               assert {:error,
                       %Ecto.Changeset{
                         changes: %{balance: 100_000, status: "open"},
                         errors: [
                           document: {"can't be blank", [validation: :required]},
                           document_type: {"can't be blank", [validation: :required]},
                           owner_name: {"can't be blank", [validation: :required]}
                         ]
                       }} = RubensBankingApi.create_new_account(params)
             end) =~ "Failed to create account in create_account"
    end

    test "returns error when there are missing parameters needed to create an account" do
      assert capture_log([level: :error], fn ->
               assert {:error, :missing_parameters} = RubensBankingApi.create_new_account(%{})
             end) =~ "Failed to create account due to missing parameters"
    end
  end

  describe "transfer_money/1" do
    test "successfully transfers money from transaction starter to receiver" do
      %{account_code: transaction_starter_account_code} = insert(:account, owner_name: "Grimes")
      %{account_code: receiver_account_code} = insert(:account, owner_name: "Tyler")

      params = %{
        "transaction_starter_account_code" => transaction_starter_account_code,
        "receiver_account_code" => receiver_account_code,
        "amount" => "5000"
      }

      assert capture_log([level: :info], fn ->
               assert {:ok,
                       %AccountTransaction{
                         transaction_starter_account_code: ^transaction_starter_account_code,
                         receiver_account_code: ^receiver_account_code,
                         amount: 5000,
                         transaction_type: "transfer money"
                       }} = RubensBankingApi.transfer_money(params)
             end) =~ "Successfully transfered R$50,00 from Grimes's account to Tyler's account"
    end

    test "returns error in case the transaction starter does not have enought money to transfer" do
      %{account_code: transaction_starter_account_code} = insert(:account, owner_name: "Snoop")
      %{account_code: receiver_account_code} = insert(:account, owner_name: "Gambino")

      params = %{
        "transaction_starter_account_code" => transaction_starter_account_code,
        "receiver_account_code" => receiver_account_code,
        "amount" => "150000"
      }

      assert capture_log([level: :error], fn ->
               assert {:error,
                       %Ecto.Changeset{
                         action: :update,
                         changes: %{balance: -50_000},
                         errors: [
                           balance:
                             {"must be greater than or equal to %{number}",
                              [validation: :number, number: 0]}
                         ],
                         valid?: false
                       }} = RubensBankingApi.transfer_money(params)
             end) =~ "Failed to transfer money in update_transaction_starter_balance"
    end

    test "returns error when trying to transfer a non-integer amount" do
      assert capture_log([level: :error], fn ->
               assert {:error, :amount_is_not_integer} ==
                        RubensBankingApi.transfer_money(%{
                          "transaction_starter_account_code" => "123",
                          "receiver_account_code" => "456",
                          "amount" => "non-integer"
                        })
             end) =~ "Failed to transfer money due to amount not being an integer"
    end

    test "returns error when there are missing parameters needed to transfer money" do
      assert capture_log([level: :error], fn ->
               assert {:error, :missing_parameters} = RubensBankingApi.transfer_money(%{})
             end) =~ "Failed to transfer money due to missing parameters"
    end
  end

  describe "withdraw/1" do
    test "successfully withdraws money from account" do
      %{account_code: account_code} = insert(:account, owner_name: "MFDOOM")
      params = %{"account_code" => account_code, "amount" => "25000"}

      assert capture_log([level: :info], fn ->
               assert {:ok,
                       %Account{
                         account_code: ^account_code,
                         balance: 75_000
                       }} = RubensBankingApi.withdraw(params)
             end) =~ "Successfully withdrew R$250,00 from MFDOOM's account"
    end

    test "returns error in case the account does not have enought money to withdraw" do
      %{account_code: account_code} = insert(:account, owner_name: "MFDOOM")
      params = %{"account_code" => account_code, "amount" => "250000"}

      assert capture_log([level: :error], fn ->
               assert {:error,
                       %Ecto.Changeset{
                         action: :update,
                         changes: %{balance: -150_000},
                         errors: [
                           balance:
                             {"must be greater than or equal to %{number}",
                              [validation: :number, number: 0]}
                         ],
                         valid?: false
                       }} = RubensBankingApi.withdraw(params)
             end) =~ "Failed to withdraw in update_account"
    end

    test "returns error when trying to withdraw a non-integer amount" do
      assert capture_log([level: :error], fn ->
               assert {:error, :amount_is_not_integer} ==
                        RubensBankingApi.withdraw(%{
                          "account_code" => "123",
                          "amount" => "non-integer"
                        })
             end) =~ "Failed to withdraw due to amount not being an integer"
    end

    test "returns error when there are missing parameters needed to withdraw" do
      assert capture_log([level: :error], fn ->
               assert {:error, :missing_parameters} = RubensBankingApi.withdraw(%{})
             end) =~ "Failed to withdraw due to missing parameters"
    end
  end

  describe "close_account/1" do
    test "successfully closes account" do
      %{account_code: account_code} = insert(:account, owner_name: "Biggie")

      capture_log([level: :info], fn ->
        assert {:ok,
                %Account{
                  owner_name: "Biggie",
                  status: "closed"
                }} = RubensBankingApi.close_account(%{"account_code" => account_code})
      end) =~ "Successfully closed Biggie's account"
    end

    test "returns error in case account is already closed" do
      %{account_code: account_code} = insert(:account, status: "closed")

      capture_log([level: :error], fn ->
        assert {:error, :account_is_already_closed} =
                 RubensBankingApi.close_account(%{"account_code" => account_code})
      end) =~ "Failed to close account in close_account"
    end

    test "returns error in case account does not exist" do
      capture_log([level: :error], fn ->
        assert {:error, :account_not_found} =
                 RubensBankingApi.close_account(%{
                   "account_code" => AccountHelper.generate_account_code()
                 })
      end) =~ "Failed to close account in get_account"
    end

    test "returns error when there are missing parameters needed to close an account" do
      assert capture_log([level: :error], fn ->
               assert {:error, :missing_parameters} = RubensBankingApi.close_account(%{})
             end) =~ "Failed to close account due to missing parameters"
    end
  end
end
