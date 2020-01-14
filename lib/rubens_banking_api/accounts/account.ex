defmodule RubensBankingApi.Accounts.Account do
  @moduledoc """
    Table that contains all accounts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:balance, :integer)
    field(:owner_name, :string)
    field(:document_type, :string)
    field(:document, :string)
    field(:status, :string)

    timestamps()
  end

  def create_account(account, attrs) do
    account
    |> cast(attrs, [
      :balance,
      :document_type,
      :document,
      :status,
      :owner_name
    ])
    |> validate_required([:document, :document_type, :owner_name, :balance, :status])
    |> validate_number(:balance, equal_to: 100_000)
    |> validate_inclusion(:status, ["open"])
  end

  def update_account_balance(account, attrs) do
    account
    |> cast(attrs, [
      :balance
    ])
    |> validate_required([:balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end

  def close_account(account) do
    account
    |> cast(%{status: "closed"}, [:status])
  end
end
