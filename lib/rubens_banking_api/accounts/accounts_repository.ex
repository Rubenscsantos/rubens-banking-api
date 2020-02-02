defmodule RubensBankingApi.Accounts.AccountsRepository do
  @moduledoc """
    Repository module to access the accounts database
  """
  alias RubensBankingApi.Accounts.Account
  alias RubensBankingApi.Repo

  alias RubensBankingApi.Helpers.AccountHelper

  import Ecto.Query

  @spec create(params :: map()) :: {:ok, Account.t()} | {:error, reason :: %Ecto.Changeset{}}
  def create(%{"account_code" => _account_code} = params) do
    case do_create(params) do
      {:error, :account_code_taken} ->
        params
        |> update_in([:account_code], nil)
        |> create()

      response ->
        response
    end
  end

  def create(params),
    do: put_in(params, ["account_code"], AccountHelper.generate_account_code()) |> create()

  defp do_create(params) do
    %Account{} |> Account.create_account(params) |> Repo.insert()
  end

  @spec get(account_code :: term()) ::
          {:ok, %Account{}} | {:error, :account_not_found} | {:error, reason :: term()}
  def get(account_code) do
    query = from(a in Account, where: a.account_code == ^account_code)

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
