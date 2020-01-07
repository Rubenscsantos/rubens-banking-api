defmodule RubensBankingApi.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:boleto_payments, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:account_id, :string)
      add(:amount, :integer)
      add(:document_type, :string)
      add(:document, :string)
      add(:status, :string)

      timestamps()
  end
end
