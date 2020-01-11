defmodule RubensBankingApiWeb.Router do
  use RubensBankingApiWeb, :router

  alias RubensBankingApiWeb.{AccountController, AccountTransactionController}

  # pipeline :browser do
  #   plug(:accepts, ["html"])
  #   plug(:fetch_session)
  #   plug(:fetch_flash)
  #   plug(:protect_from_forgery)
  #   plug(:put_secure_browser_headers)
  # end
  pipeline :api do
    plug(:accepts, ["json"])
  end

  # scope "/", RubensBankingApiWeb do
  #   # Use the default browser stack
  #   pipe_through(:browser)

  #   get("/", PageController, :index)
  # end

  scope "/" do
    # get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/docs/api.yaml"
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

  # Other scopes may use custom stacks.
  # scope "/api", RubensBankingApiWeb do
  #   pipe_through :api
  # end
end
