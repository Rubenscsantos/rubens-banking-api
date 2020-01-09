defmodule RubensBankingApi.Repo.Migrations.CreateAccountTransactions do
  use Ecto.Migration

  def change do
    create table(:account_transactions) do
      add(:transaction_starter_account_id, :integer)
      add(:receiver_account_id, :integer)
      add(:transaction_type, :string)
      add(:amount, :bigint)

      timestamps()
    end
  end
end
