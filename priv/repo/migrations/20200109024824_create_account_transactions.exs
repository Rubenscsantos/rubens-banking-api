defmodule RubensBankingApi.Repo.Migrations.CreateAccountTransactions do
  use Ecto.Migration

  def change do
    create table(:account_transactions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:transaction_starter_account_id, :integer)
      add(:receiver_account_id, :integer)
      add(:transaction_type, :string)
      add(:amount, :bigint)

      timestamps()
    end
  end
end
