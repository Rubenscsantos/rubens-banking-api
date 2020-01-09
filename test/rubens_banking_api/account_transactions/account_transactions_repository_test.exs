defmodule RubensBankingApi.AccountTransactions.AccountTransactionsRepositoryTest do
  use RubensBankingApi.DataCase, async: true
  alias RubensBankingApi.Repo
  alias RubensBankingApi.AccountTransactions.{AccountTransaction, AccountTransactionsRepository}

  describe "create_account_transaction/1" do
    test "returns error when transaction_type is missing" do
      new_account_transaction = %{}

      assert {:error,
              %Ecto.Changeset{
                errors: [transaction_type: {"can't be blank", [validation: :required]}],
                valid?: false
              }} =
               AccountTransactionsRepository.create_account_transaction(new_account_transaction)

      assert [] == Repo.all(AccountTransaction)
    end

    test "returns error when transaction_type is not valid" do
      new_account_transaction = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "invalid_type"
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [transaction_type: {"Invalid status", [validation: :inclusion]}],
                valid?: false
              }} =
               AccountTransactionsRepository.create_account_transaction(new_account_transaction)
    end
  end

  describe "create_account_transaction/1 when transaction_type = 'open_account'" do
    test "successfully creates an account transaction" do
      new_account_transaction = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "open_account",
        amount: 100_000
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} =
               AccountTransactionsRepository.create_account_transaction(new_account_transaction)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "create_account_transaction/1 when transaction_type = 'close_account'" do
    test "successfully creates an account transaction" do
      new_account_transaction = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "close_account"
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} =
               AccountTransactionsRepository.create_account_transaction(new_account_transaction)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "create_account_transaction/1 when transaction_type = 'transfer_money'" do
    test "successfully creates an account transaction" do
      new_account_transaction = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        receiver_account_id: Enum.random(1..100_000),
        transaction_type: "transfer_money",
        amount: Enum.random(1..500_000)
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} =
               AccountTransactionsRepository.create_account_transaction(new_account_transaction)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end

  describe "create_account_transaction/1 when transaction_type = 'withdraw'" do
    test "successfully creates an account transaction" do
      new_account_transaction = %{
        transaction_starter_account_id: Enum.random(1..100_000),
        transaction_type: "withdraw",
        amount: Enum.random(1..500_000)
      }

      assert [] == Repo.all(AccountTransaction)

      assert {:ok, %AccountTransaction{}} =
               AccountTransactionsRepository.create_account_transaction(new_account_transaction)

      refute Enum.empty?(Repo.all(AccountTransaction))
    end
  end
end
