defmodule RubensBankingApi.AccountTransactions.AccountTransactions do
  @moduledoc false
  alias RubensBankingApi.AccountTransactions.AccountTransactionsRepository

  def get_report(%{"account_id" => account_id, "report_period" => report_period}) do
    AccountTransactionsRepository.generate_report(account_id, String.to_atom(report_period))
  end

  def get_report(_params), do: {:error, :missing_params}
end
