defmodule RubensBankingApi.Repo.Migrations.AddReferenceToUser do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      add :user_id, references(:users, column: :id, type: :uuid)
    end

    create index(:accounts, [:user_id])
  end
end
