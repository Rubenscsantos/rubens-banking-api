defmodule RubensBankingApiWeb.Router do
  use RubensBankingApiWeb, :router

  alias RubensBankingApiWeb.{AccountController, AccountTransactionController, UserController}

  alias RubensBankingApi.{Auth, Auth.User}

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  pipeline :api_auth do
    plug(:ensure_authenticated)
  end

  scope "/api/v1" do
    pipe_through([:api])

    scope "/accounts" do
      pipe_through([:api_auth])

      post("/", AccountController, :create)
      get("/:account_code", AccountController, :show)
      post("/:account_code/close", AccountController, :close)
      post("/withdraw", AccountController, :withdraw)
      post("/transfer_money", AccountController, :transfer_money)
    end

    scope "/account_transactions" do
      pipe_through([:api_auth])

      post("/get_report", AccountTransactionController, :get_report)
    end

    post("/users", UserController, :create)
    post("/sign_in", UserController, :sign_in)

    scope "/users" do
      pipe_through([:api_auth])

      resources("/", UserController, except: [:create, :new, :edit])
      # get("/accounts", UserController, :accounts)
    end
  end

  # Plug function
  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)

    case Auth.get_user(current_user_id) do
      {:ok, %User{}} ->
        conn

      _error ->
        conn
        |> put_status(:unauthorized)
        |> put_view(RubensBankingApiWeb.ErrorView)
        |> render("401.json", message: "Unauthenticated user")
        |> halt()
    end
  end
end
