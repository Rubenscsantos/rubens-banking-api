defmodule RubensBankingApi.Repo.Migrations.CreateAccountCodeField do
  use Ecto.Migration

  def up do
    alter table(:accounts, primary_key: false) do
      remove(:id)
      add(:id, :binary_id, primary_key: true)
      add(:account_code, :string)
    end
  end
  
  def down do
    alter table(:accounts, primary_key: true) do
      remove(:id)
      remove(:account_code)
    end
  end
end
