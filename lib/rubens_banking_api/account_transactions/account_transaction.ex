defmodule RubensBankingApi.AccountTransactions.AccountTransaction do
  @moduledoc """
    Table that contains all transactions made, used to generate reports
    for account transactions.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @transaction_types ["open account", "close account", "transfer money", "withdraw"]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "account_transactions" do
    field(:transaction_starter_account_code, :string)
    field(:receiver_account_code, :string)
    field(:transaction_type, :string)
    field(:amount, :integer)

    timestamps()
  end

  def changeset(account_transaction, attrs) do
    account_transaction
    |> cast(attrs, [
      :transaction_starter_account_code,
      :receiver_account_code,
      :transaction_type,
      :amount
    ])
    |> validate_required([:transaction_type])
    |> validate_requirements(Map.get(attrs, :transaction_type))
  end

  defp validate_requirements(changeset, "open account") do
    changeset
    |> validate_required([:transaction_starter_account_code, :amount])
  end

  defp validate_requirements(changeset, "close account") do
    changeset
    |> validate_required([:transaction_starter_account_code])
  end

  defp validate_requirements(changeset, "transfer money") do
    changeset
    |> validate_required([
      :transaction_starter_account_code,
      :receiver_account_code,
      :amount
    ])
  end

  defp validate_requirements(changeset, "withdraw") do
    changeset
    |> validate_required([:transaction_starter_account_code, :amount])
  end

  defp validate_requirements(changeset, _invalid_type),
    do: changeset |> validate_transaction_type()

  defp validate_transaction_type(changeset) do
    changeset
    |> validate_inclusion(:transaction_type, @transaction_types, message: "Invalid status")
  end
end
