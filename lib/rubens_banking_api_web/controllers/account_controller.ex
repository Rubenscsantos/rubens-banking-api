defmodule RubensBankingApiWeb.AccountController do
  use RubensBankingApiWeb, :controller

  action_fallback(RubensBankingApiWeb.FallbackController)

  alias RubensBankingApi.Auth

  def create(conn, account_params) do
    user_id = Map.get(conn.private.plug_session, "current_user_id")
    account_params = Map.put(account_params, "user_id", user_id)

    with {:ok, account} <- RubensBankingApi.create_new_account(account_params) do
      conn
      |> put_status(201)
      |> render("show.json", account: account)
    end
  end

  def show(conn, account_params) do
    account_code = Map.get(account_params, "account_code")
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with {:ok, :authorized_operation} <- Auth.authorize_operation(user_id, account_code),
         {:ok, account} <- RubensBankingApi.get_account(account_code) do
      conn
      |> put_status(200)
      |> render("show.json", account: account)
    end
  end

  def close(conn, account_params) do
    account_code = Map.get(account_params, "account_code")
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with {:ok, :authorized_operation} <- Auth.authorize_operation(user_id, account_code),
         {:ok, account} <- RubensBankingApi.close_account(account_params) do
      conn
      |> put_status(200)
      |> render("show.json", account: account)
    end
  end

  def withdraw(conn, account_params) do
    account_code = Map.get(account_params, "account_code")
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with {:ok, :authorized_operation} <- Auth.authorize_operation(user_id, account_code),
         {:ok, account} <- RubensBankingApi.withdraw(account_params) do
      conn
      |> put_status(200)
      |> render("show.json", account: account)
    end
  end

  def transfer_money(conn, account_params) do
    account_code = Map.get(account_params, "transaction_starter_account_code")
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with {:ok, :authorized_operation} <- Auth.authorize_operation(user_id, account_code),
         {:ok, account_transaction} <- RubensBankingApi.transfer_money(account_params) do
      conn
      |> put_status(200)
      |> render("show.json", account_transaction: account_transaction)
    end
  end
end
