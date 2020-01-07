defmodule RubensBankingApiWeb.Router do
  use RubensBankingApiWeb, :router

  alias RubensBankingApiWeb.AccountsController

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", RubensBankingApiWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api/v1" do
    pipe_through(:api)

    scope "/accounts", RubensBankingApiWeb do
      post("/", AccountsController, :create)
      get("/", AccountsController, :show_all)
      get("/:account_id", AccountsController, :show)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", RubensBankingApiWeb do
  #   pipe_through :api
  # end
end
