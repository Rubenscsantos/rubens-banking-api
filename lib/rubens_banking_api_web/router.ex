defmodule RubensBankingApiWeb.Router do
  use RubensBankingApiWeb, :router

  alias RubensBankingApiWeb.{AccountController, AccountTransactionController}

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1" do
    pipe_through(:api)

    scope "/accounts" do
      post("/", AccountController, :create)
      get("/:account_id", AccountController, :show)
      post("/:account_id/close", AccountController, :close)
      post("/withdraw", AccountController, :withdraw)
      post("/transfer_money", AccountController, :transfer_money)
    end

    scope "/account_transactions" do
      post("/get_report", AccountTransactionController, :get_report)
    end
  end
end
