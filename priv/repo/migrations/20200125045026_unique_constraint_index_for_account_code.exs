defmodule RubensBankingApi.Repo.Migrations.UniqueConstraintIndexForAccountCode do
  use Ecto.Migration

  def change do
    create unique_index(:accounts, [:account_code])
  end
end
