defmodule RubensBankingApi.Accounts.AccountsRepository do
  @moduledoc """
    Repository module to access the accounts database
  """
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
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end

  @spec get_all() :: list(%Account{})
  def get_all do
    Repo.all(Account)
  end

  @spec update_account_balance(account :: Account.t(), params :: map()) ::
          {:ok, Account.t()} | {:error, :cannot_update_closed_account} | {:error, reason :: any()}
  def update_account_balance(%{status: "closed"}, _params),
    do: {:error, :cannot_update_closed_account}

  def update_account_balance(account, params) do
    account |> Account.update_account_balance(params) |> Repo.update()
  end

  @spec close_account(account :: Account.t()) ::
          {:ok, Account.t()} | {:error, :account_is_already_closed} | {:error, reason :: any()}
  def close_account(%{status: "closed"}), do: {:error, :account_is_already_closed}

  def close_account(account) do
    account |> Account.close_account() |> Repo.update()
  end
end
