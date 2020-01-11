defmodule RubensBankingApi.Accounts.AccountsRepositoryTest do
  use RubensBankingApi.DataCase, async: true
  alias RubensBankingApi.Repo
  alias RubensBankingApi.Accounts.{Account, AccountsRepository}

  describe "create/1" do
    test "successfully creates an account" do
      new_account = %{
        balance: 100_000,
        document: "1234554321",
        document_type: "RG",
        owner_name: "Bjork",
        status: "open"
      }

      assert [] == Repo.all(Account)

      assert {:ok, %Account{}} = AccountsRepository.create(new_account)

      refute Enum.empty?(Repo.all(Account))
    end

    test "returns error when required fields are missing" do
      new_account = %{}

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  document: {"can't be blank", [validation: :required]},
                  document_type: {"can't be blank", [validation: :required]},
                  owner_name: {"can't be blank", [validation: :required]},
                  balance: {"can't be blank", [validation: :required]},
                  status: {"can't be blank", [validation: :required]}
                ],
                valid?: false
              }} = AccountsRepository.create(new_account)

      assert [] == Repo.all(Account)
    end

    test "returns error when balance is not R$1000,00 on creation" do
      new_account = %{
        balance: 10,
        document: "1234554321",
        document_type: "RG",
        owner_name: "Tom",
        status: "open"
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  balance: {"must be equal to %{number}", [validation: :number, number: 100_000]}
                ],
                valid?: false
              }} = AccountsRepository.create(new_account)
    end

    test "returns error when status is not open on creation" do
      new_account = %{
        balance: 100_000,
        document: "1234554321",
        document_type: "RG",
        owner_name: "Tom",
        status: "closed"
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [status: {"is invalid", [validation: :inclusion]}],
                valid?: false
              }} = AccountsRepository.create(new_account)
    end
  end

  describe "get/1" do
    test "successfully returns an account" do
      %{id: account_id} = account = insert(:account)

      assert {:ok, account} == AccountsRepository.get(account_id)
    end

    test "returns `{:error, :account_not_found}` if there is no account with given id" do
      assert {:error, :account_not_found} == AccountsRepository.get(1)
    end
  end

  describe "get_all/0" do
    test "returns all accounts present in database" do
      assert [] = AccountsRepository.get_all()

      insert(:account)

      refute Enum.empty?(AccountsRepository.get_all())
    end
  end

  describe "update_account_balance/2" do
    test "successfully updates account balance" do
      account = insert(:account)

      assert {:ok, %Account{balance: 10}} =
               AccountsRepository.update_account_balance(account, %{balance: 10})
    end

    test "returns error in case new balance is less than 0" do
      account = insert(:account)

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  balance:
                    {"must be greater than or equal to %{number}",
                     [validation: :number, number: 0]}
                ],
                valid?: false
              }} = AccountsRepository.update_account_balance(account, %{balance: -1})
    end

    test "returns error in case account is already closed" do
      account = insert(:account, status: "closed")

      assert {:error, :cannot_update_closed_account} ==
               AccountsRepository.update_account_balance(account, %{})
    end
  end

  describe "close_account/1" do
    test "successfully closes account" do
      account = insert(:account)

      assert {:ok, %Account{status: "closed"}} = AccountsRepository.close_account(account)
    end

    test "returns error in case account is already closed" do
      account = insert(:account, status: "closed")
      assert {:error, :account_is_already_closed} == AccountsRepository.close_account(account)
    end
  end
end
