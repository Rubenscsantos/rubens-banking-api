defmodule RubensBankingApi.Accounts.AccountsRepository do
  alias RubensBankingApi.Accounts.Account
  alias RubensBankingApi.Repo

  import Ecto.Query

  @spec create(params :: map()) :: {:ok, Account.t()} | {:error, reason :: %Ecto.Changeset{}}
  def create(params) do
    %Account{} |> Account.create_account(params) |> Repo.insert()
  end

  @spec get(id :: term()) ::
          {:ok, %Account{}} | {:error, :account_not_found} | {:error, reason :: term()}
  def get(id) do
    query = from(a in Account, where: a.id == ^id)

    case Repo.one(query) do
      nil -> {:ok, :account_not_found}
      account -> {:ok, account}
    end
  end

  @spec get_all() :: list(%Account{})
  def get_all() do
    Repo.all(Account)
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
