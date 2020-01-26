defmodule RubensBankingApi.Repo.Migrations.RemoveBinaryIdFromAccountTable do
  use Ecto.Migration

  def up do
    alter table(:accounts) do
      remove(:id)
      modify(:account_code, :string, primary_key: true)
    end
  end

  def down do
    alter table(:accounts) do
      add(:id, :binary_id, primary_key: true)
      modify(:account_code, :string, primary_key: false)
    end
  end
end
