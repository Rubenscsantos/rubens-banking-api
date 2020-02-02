defmodule RubensBankingApiWeb.AccountTransactionController do
  use RubensBankingApiWeb, :controller

  action_fallback(RubensBankingApiWeb.FallbackController)

  alias RubensBankingApi.Auth

  def get_report(conn, report_params) do
    account_code = Map.get(report_params, "account_code")
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with {:ok, :authorized_operation} <- Auth.authorize_operation(user_id, account_code),
         {:ok, account_transaction} <- RubensBankingApi.get_report(report_params) do
      conn
      |> put_status(201)
      |> render("show.json", account_transaction: account_transaction)
    end
  end
end
