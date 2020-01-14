defmodule RubensBankingApiWeb.AccountTransactionController do
  use RubensBankingApiWeb, :controller

  action_fallback(RubensBankingApiWeb.FallbackController)

  def get_report(conn, report_params) do
    with {:ok, account_transaction} <- RubensBankingApi.get_report(report_params) do
      conn
      |> put_status(201)
      |> render("show.json", account_transaction: account_transaction)
    end
  end
end
