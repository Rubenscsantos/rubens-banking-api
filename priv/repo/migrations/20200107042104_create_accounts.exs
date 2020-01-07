defmodule RubensBankingApi.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: true) do
      add(:account_id, :string)
      add(:amount, :integer)
      add(:document_type, :string)
      add(:document, :string)
      add(:status, :string)

      timestamps()
    end
  end
end
