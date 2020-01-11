defmodule RubensBankingApiWeb.AccountController do
  use RubensBankingApiWeb, :controller

  alias RubensBankingApi.Accounts.Accounts

  action_fallback(RubensBankingApiWeb.FallbackController)

  def create(conn, account_params) do
    with {:ok, account} <- RubensBankingApi.create_new_account(account_params) do
      conn
      |> put_status(201)
      |> render("show.json", account: account)
    end
  end

  def show(conn, account_params) do
    id = Map.get(account_params, "account_id")

    with {:ok, account} <- Accounts.get_account(id) do
      conn
      |> put_status(200)
      |> render("show.json", account: account)
    end
  end

  def close(conn, account_params) do
    with {:ok, account} <- RubensBankingApi.close_account(account_params) do
      conn
      |> put_status(201)
      |> render("show.json", account: account)
    end
  end

  def withdraw(conn, account_params) do
    with {:ok, account} <- RubensBankingApi.withdraw(account_params) do
      conn
      |> put_status(201)
      |> render("show.json", account: account)
    end
  end

  def transfer_money(conn, account_params) do
    with {:ok, account_transaction} <- RubensBankingApi.transfer_money(account_params) do
      conn
      |> put_status(201)
      |> render("show.json", account_transaction: account_transaction)
    end
  end
end
