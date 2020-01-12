defmodule RubensBankingApi.Accounts.Accounts do
  @moduledoc false
  alias RubensBankingApi.Accounts.AccountsRepository

  @spec get_account(id :: String.t()) ::
          {:error, :account_not_found} | {:ok, RubensBankingApi.Accounts.Account.t()}
  def get_account(id) do
    AccountsRepository.get(id)
  end
end
