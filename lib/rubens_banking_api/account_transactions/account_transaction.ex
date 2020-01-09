defmodule RubensBankingApi.AccountTransactions.AccountTransaction do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @transaction_types ["open_account", "close_account", "transfer_money", "withdraw"]

  schema "account_transactions" do
    field(:transaction_starter_account_id, :integer)
    field(:receiver_account_id, :integer)
    field(:transaction_type, :string)
    field(:amount, :integer)

    timestamps()
  end

  def changeset(account_transaction, attrs) do
    account_transaction
    |> cast(attrs, [
      :transaction_starter_account_id,
      :receiver_account_id,
      :transaction_type,
      :amount
    ])
    |> validate_required([:transaction_type])
    |> validate_requirements(Map.get(attrs, :transaction_type))
  end

  # def changeset(_account_transaction, _attrs), do: {:error, :transaction_type_missing}

  defp validate_requirements(changeset, "open_account") do
    changeset
    |> validate_required([:transaction_starter_account_id, :amount])
    |> validate_transaction_type()
  end

  defp validate_requirements(changeset, "close_account") do
    changeset
    |> validate_required([:transaction_starter_account_id])
    |> validate_transaction_type()
  end

  defp validate_requirements(changeset, "transfer_money") do
    changeset
    |> validate_required([
      :transaction_starter_account_id,
      :receiver_account_id,
      :amount
    ])
    |> validate_transaction_type()
  end

  defp validate_requirements(changeset, "withdraw") do
    changeset
    |> validate_required([:transaction_starter_account_id, :amount])
    |> validate_transaction_type()
  end

  defp validate_requirements(changeset, _invalid_type),
    do: changeset |> validate_transaction_type()

  defp validate_transaction_type(changeset) do
    changeset
    |> validate_inclusion(:transaction_type, @transaction_types, message: "Invalid status")
  end
end
