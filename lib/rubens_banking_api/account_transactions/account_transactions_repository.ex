defmodule RubensBankingApi.AccountTransactions.AccountTransactionsRepository do
  alias RubensBankingApi.AccountTransactions.AccountTransaction
  alias RubensBankingApi.Repo

  @spec create_account_transaction(params :: map()) ::
          {:ok, Account.t()} | {:error, reason :: %Ecto.Changeset{}}
  def create_account_transaction(params) do
    %AccountTransaction{}
    |> AccountTransaction.changeset(params)
    |> Repo.insert()
  end
end
