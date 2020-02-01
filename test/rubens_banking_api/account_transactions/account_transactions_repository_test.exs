defmodule RubensBankingApi.AccountTransactions.AccountTransactionsRepositoryTest do
  use RubensBankingApi.DataCase, async: true

  alias RubensBankingApi.Repo

  alias RubensBankingApi.AccountTransactions.{AccountTransaction, AccountTransactionsRepository}

  alias RubensBankingApi.Factories.Factory

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
        transaction_starter_account_code: Factory.generate_account_code(),
        transaction_type: "invalid_type"
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [transaction_type: {"Invalid status", [validation: :inclusion]}],
                valid?: false
              }} = AccountTransactionsRepository.create(params)
    end
  end

  describe "create/1 when transaction_type = 'open account'" do
    test "successfully creates an account transaction" do
      params = %{
        transaction_starter_account_code: Factory.generate_account_code(),
        transaction_type: "open account",
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
        transaction_starter_account_code: Factory.generate_account_code(),
        transaction_type: "close account"
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} = AccountTransactionsRepository.create(params)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "create/1 when transaction_type = 'transfer_money'" do
    test "successfully creates an account transaction" do
      params = %{
        transaction_starter_account_code: Factory.generate_account_code(),
        receiver_account_code: Factory.generate_account_code(),
        transaction_type: "transfer money",
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
        transaction_starter_account_code: Factory.generate_account_code(),
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
      %{account_code: account_code} = build(:account)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_code: account_code)

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        inserted_at: next_day(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_code, :day)
    end
  end

  describe "generate_report/2 for last week" do
    test "successfullt return a list of all transactions done by an account in the last week" do
      %{account_code: account_code} = build(:account)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_code: account_code)

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        inserted_at: next_week(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_code, :week)
    end
  end

  describe "generate_report/2 for last month" do
    test "successfullt return a list of all transactions done by an account in the last month" do
      %{account_code: account_code} = build(:account)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction,
        transaction_starter_account_code: account_code,
        inserted_at: now
      )

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        inserted_at: next_month(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_code, :month)
    end
  end

  describe "generate_report/2 for last year" do
    test "successfullt return a list of all transactions done by an account in the last year" do
      %{account_code: account_code} = build(:account)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_code: account_code)

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        inserted_at: next_year(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_code, :year)
    end
  end

  describe "generate_report/2 for all time" do
    test "successfullt return a list of all transactions done by an account" do
      %{account_code: account_code} = build(:account)
      now = NaiveDateTime.utc_now()

      insert_pair(:account_transaction, transaction_starter_account_code: account_code)

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        inserted_at: two_years_from_now(now),
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "withdraw"
                }
              ]} = AccountTransactionsRepository.generate_report(account_code, :total)
    end
  end

  describe "generate_report/2" do
    test "successfully returns a list of all transactions done by an account if they are either transaction starters or receivers" do
      %{account_code: account_code} = build(:account)

      insert_pair(:account_transaction, transaction_starter_account_code: account_code)
      insert(:account_transaction, receiver_account_code: account_code)

      assert {:ok,
              [
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  transaction_starter_account_code: ^account_code,
                  transaction_type: "transfer money"
                },
                %AccountTransaction{
                  receiver_account_code: ^account_code,
                  transaction_type: "transfer money"
                }
              ]} = AccountTransactionsRepository.generate_report(account_code, :total)
    end

    test "successfully returns a list of all transactions by an account even if transaction types are different" do
      %{account_code: account_code} = build(:account)

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        transaction_type: "open account"
      )

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        transaction_type: "close account"
      )

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        transaction_type: "transfer money"
      )

      insert(:account_transaction,
        transaction_starter_account_code: account_code,
        transaction_type: "withdraw"
      )

      assert {:ok,
              [
                %AccountTransaction{transaction_type: "open account"},
                %AccountTransaction{transaction_type: "close account"},
                %AccountTransaction{transaction_type: "transfer money"},
                %AccountTransaction{transaction_type: "withdraw"}
              ]} = AccountTransactionsRepository.generate_report(account_code, :total)
    end

    test "returns `{:ok, []}` when no entries are found in the report" do
      assert {:ok, []} ==
               AccountTransactionsRepository.generate_report(
                 Factory.generate_account_code(),
                 :total
               )
    end

    test "return `{:error, :invalid_report_period}` when report_duration is of inexpected value" do
      assert {:error, :invalid_report_period} ==
               AccountTransactionsRepository.generate_report("", :trimester)
    end
  end

  defp next_day(now), do: now |> NaiveDateTime.add(@seconds_in_day, :second)
  defp next_week(now), do: now |> NaiveDateTime.add(@seconds_in_week, :second)

  defp next_month(now),
    do: now |> Map.put(:month, now.month + 1) |> NaiveDateTime.add(@seconds_in_week, :second)

  defp next_year(now), do: now |> Map.put(:year, now.year + 1)
  defp two_years_from_now(now), do: now |> Map.put(:year, now.year + 2)
end
