defmodule RubensBankingApi.AccountTransactions.AccountTransactionsRepositoryTest do
  use RubensBankingApi.DataCase, async: true
  alias RubensBankingApi.Repo
  alias RubensBankingApi.AccountTransactions.{AccountTransaction, AccountTransactionsRepository}

  @seconds_in_day 86_400
  @seconds_in_week 604_800

  describe "create/1" do
    test "returns error when transaction_type is missing" do
      params = %{}

      assert {:error,
              %Ecto.Changeset{
                errors: [transaction_type: {"can't be blank", [validation: :required]}],
                valid?: false
              }} = AccountTransactionsRepository.create(params)

      assert [] == Repo.all(AccountTransaction)
    end

    test "returns error when transaction_type is not valid" do
      params = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "invalid_type"
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [transaction_type: {"Invalid status", [validation: :inclusion]}],
                valid?: false
              }} = AccountTransactionsRepository.create(params)
    end
  end

  describe "create/1 when transaction_type = 'open_account'" do
    test "successfully creates an account transaction" do
      params = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "open_account",
        amount: 100_000
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} = AccountTransactionsRepository.create(params)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "create/1 when transaction_type = 'close_account'" do
    test "successfully creates an account transaction" do
      params = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "close_account"
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} = AccountTransactionsRepository.create(params)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "create/1 when transaction_type = 'transfer_money'" do
    test "successfully creates an account transaction" do
      params = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        receiver_account_id: Enum.random(1..100_000),
        transaction_type: "transfer_money",
        amount: Enum.random(1..500_000)
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} = AccountTransactionsRepository.create(params)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "create/1 when transaction_type = 'withdraw'" do
    test "successfully creates an account transaction" do
      params = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "withdraw",
        amount: Enum.random(1..500_000)
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} = AccountTransactionsRepository.create(params)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "get/1" do
    test "given an existing id, returns an account transaction" do
      %AccountTransaction{id: id} = insert(:account_transaction)

      assert {:ok, %AccountTransaction{id: ^id}} = AccountTransactionsRepository.get(id)
    end

    test "given a non-existing id, returns a `{:error, :account_transaction_not_found}` error" do
      assert {:error, :account_transaction_not_found} ==
               AccountTransactionsRepository.get(Ecto.UUID.generate())
    end
  end

  describe "generate_report/2 for last day" do
    test "successfullt return a list of all transactions done by an account in the last day" do
      account_id = Enum.random(1..100_000)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_id: account_id)

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        inserted_at: next_day(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_id, :day)
    end
  end

  describe "generate_report/2 for last week" do
    test "successfullt return a list of all transactions done by an account in the last week" do
      account_id = Enum.random(1..100_000)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_id: account_id)

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        inserted_at: next_week(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_id, :week)
    end
  end

  describe "generate_report/2 for last month" do
    test "successfullt return a list of all transactions done by an account in the last month" do
      account_id = Enum.random(1..100_000)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_id: account_id)

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        inserted_at: next_month(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_id, :month)
    end
  end

  describe "generate_report/2 for last year" do
    test "successfullt return a list of all transactions done by an account in the last year" do
      account_id = Enum.random(1..100_000)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_id: account_id)

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        inserted_at: next_year(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_id, :year)
    end
  end

  describe "generate_report/2 for all time" do
    test "successfullt return a list of all transactions done by an account" do
      account_id = Enum.random(1..100_000)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_id: account_id)

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        inserted_at: two_years_from_now(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "withdraw"
                }
              ]} = AccountTransactionsRepository.generate_report(account_id, :total)
    end
  end

  describe "generate_report/2" do
    test "successfully returns a list of all transactions done by an account if they are either transaction starters or receivers" do
      account_id = Enum.random(1..100_000)

      insert_pair(:account_transaction, transaction_starter_account_id: account_id)
      insert(:account_transaction, receiver_account_id: account_id)

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  transaction_starter_account_id: ^account_id,
                  transaction_type: "transfer_money"
                },
                %AccountTransaction{
                  receiver_account_id: ^account_id,
                  transaction_type: "transfer_money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_id, :total)
    end

    test "successfully returns a list of all transactions by an account even if transaction types are different" do
      account_id = Enum.random(1..100_000)

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        transaction_type: "open_account"
      )

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        transaction_type: "close_account"
      )

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        transaction_type: "transfer_money"
      )

      insert(:account_transaction,
        transaction_starter_account_id: account_id,
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{transaction_type: "open_account"},
                %AccountTransaction{transaction_type: "close_account"},
                %AccountTransaction{transaction_type: "transfer_money"},
                %AccountTransaction{transaction_type: "withdraw"}
              ]} = AccountTransactionsRepository.generate_report(account_id, :total)
    end

    test "returns `{:ok, []}` when no entries are found in the report" do
      assert {:ok, []} ==
               AccountTransactionsRepository.generate_report(Enum.random(1..100_000), :total)
    end

    test "return `{:error, :invalid_report_duration}` when report_duration is of inexpected value" do
      assert {:error, :invalid_report_duration} ==
               AccountTransactionsRepository.generate_report("", :trimester)
    end
  end

  defp next_day(now), do: now |> NaiveDateTime.add(@seconds_in_day, :second)
  defp next_week(now), do: now |> NaiveDateTime.add(@seconds_in_week, :second)
  defp next_month(now), do: now |> Map.put(:month, now.month + 1)
  defp next_year(now), do: now |> Map.put(:year, now.year + 1)
  defp two_years_from_now(now), do: now |> Map.put(:year, now.year + 2)
end
