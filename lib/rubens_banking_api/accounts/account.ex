defmodule RubensBankingApi.Accounts.Account do
  @moduledoc """
    Table that contains all accounts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:account_code, :string, autogenerate: false}

  schema "accounts" do
    field(:balance, :integer)
    field(:owner_name, :string)
    field(:document_type, :string)
    field(:document, :string)
    field(:status, :string)

    belongs_to(:user, RubensBankingApi.Users.User, type: :binary_id)

    has_many(
      :transaction_starter_account_transactions,
      RubensBankingApi.AccountTransactions.AccountTransaction,
      foreign_key: :transaction_starter_account_code
    )

    has_many(
      :receiver_account_transactions,
      RubensBankingApi.AccountTransactions.AccountTransaction,
      foreign_key: :receiver_account_code
    )

    timestamps()
  end

  def create_account(account, attrs) do
    account
    |> cast(attrs, [
      :balance,
      :document_type,
      :document,
      :status,
      :owner_name,
      :account_code,
      :user_id
    ])
    |> validate_required([
      :document,
      :document_type,
      :owner_name,
      :balance,
      :status,
      :account_code
    ])
    |> update_change(:account_code, &String.trim_leading(&1, "0"))
    |> unique_constraint(:account_code)
    |> validate_number(:balance, equal_to: 100_000)
    |> validate_inclusion(:status, ["open"])
  end

  def update_account_balance(account, attrs) do
    account
    |> cast(attrs, [
      :balance,
      :user_id
    ])
    |> validate_required([:balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end

  def close_account(account) do
    account
    |> cast(%{status: "closed"}, [:status])
  end
end
