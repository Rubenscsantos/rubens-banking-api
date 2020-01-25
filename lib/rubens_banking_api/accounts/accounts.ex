defmodule RubensBankingApi.Accounts do
  @moduledoc """
    Abstraction for AccountsRepository
  """
  alias RubensBankingApi.Accounts.{Account, AccountsRepository}

  @spec create_account(params :: map()) ::
          {:ok, Account.t()} | {:error, reason :: %Ecto.Changeset{}}
  def create_account(account_params) do
    AccountsRepository.create(account_params)
  end

  @spec get_account(account_code :: String.t()) ::
          {:error, :account_not_found} | {:ok, RubensBankingApi.Accounts.Account.t()}
  def get_account(account_code) do
    AccountsRepository.get(account_code)
  end

  @spec update_account_balance(account :: Account.t(), params :: map()) ::
          {:ok, Account.t()} | {:error, :cannot_update_closed_account} | {:error, reason :: any()}
  def update_account_balance(account, params) do
    AccountsRepository.update_account_balance(account, params)
  end

  @spec close_account(account :: Account.t()) ::
          {:ok, Account.t()} | {:error, :account_is_already_closed} | {:error, reason :: any()}
  def close_account(account) do
    AccountsRepository.close_account(account)
  end
end
