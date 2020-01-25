defmodule RubensBankingApi.Repo.Migrations.ModifyAccountTransactionsFields do
  use Ecto.Migration

  def change do
    alter table(:account_transactions) do
      modify(:transaction_starter_account_code, :string)
      modify(:receiver_account_code, :string)
    end
  end
end
