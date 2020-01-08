defmodule RubensBankingApi.Accounts.AccountsRepository do
  alias RubensBankingApi.Accounts.Account
  alias RubensBankingApi.Repo

  @spec create(params :: map()) :: {:ok, Account.t()} | {:error, reason :: %Ecto.Changeset{}}
  def create(params) do
    %Account{} |> Account.create_account(params) |> Repo.insert()
  end

  @spec update_account_balance(account :: Account.t(), params :: map()) ::
          {:ok, Account.t()} | {:error, reason :: any()}
  def update_account_balance(account, params) do
    account |> Account.update_account_balance(params) |> Repo.update()
  end

  @spec close_account(account :: Account.t()) :: {:ok, Account.t()} | {:error, reason :: any()}
  def close_account(account) do
    account |> Account.close_account() |> Repo.update()
  end
end
