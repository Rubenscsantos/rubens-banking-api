defmodule RubensBankingApi.Repo.Migrations.AddAccountCodeReferenceToAccountTransactions do
  use Ecto.Migration

  def change do
    alter table(:account_transactions) do
      remove(:transaction_starter_account_code)
      remove(:receiver_account_code)

      add(:transaction_starter_account_code, references(:accounts, column: :account_code, type: :string))
      add(:receiver_account_code, references(:accounts, column: :account_code, type: :string))
    end
  end
end
