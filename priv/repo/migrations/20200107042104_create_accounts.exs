defmodule RubensBankingApi.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: true) do
      add(:account_id, :string)
      add(:balance, :integer)
      add(:owner_name, :string)
      add(:document_type, :string)
      add(:document, :string)
      add(:status, :string)

      timestamps()
    end
  end
end
