defmodule RubensBankingApi.AccountTransactions do
  @moduledoc """
    Abstraction for AccountTransactionsRepository
  """
  alias RubensBankingApi.AccountTransactions.{AccountTransaction, AccountTransactionsRepository}

  @spec create_account_transaction(params :: map()) ::
          {:ok, AccountTransaction.t()} | {:error, reason :: %Ecto.Changeset{}}
  def create_account_transaction(params) do
    AccountTransactionsRepository.create(params)
  end

  def get_report(%{"account_id" => account_id, "report_period" => report_period}) do
    AccountTransactionsRepository.generate_report(account_id, String.to_atom(report_period))
  end

  def get_report(_params), do: {:error, :missing_params}
end
