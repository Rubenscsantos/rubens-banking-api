defmodule RubensBankingApiWeb.Router do
  use RubensBankingApiWeb, :router

  alias RubensBankingApiWeb.{AccountController, AccountTransactionController, UserController}

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  pipeline :api_auth do
    plug(:ensure_authenticated)
  end

  scope "/api/v1" do
    pipe_through([:api, :api_auth])

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

    scope "/users" do
      resources("/", UserController, except: [:new, :edit])
      post("/sign_in", UserController, :sign_in)
    end
  end

  # Plug function
  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)

    if current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(MyAppWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user")
      |> halt()
    end
  end
end
