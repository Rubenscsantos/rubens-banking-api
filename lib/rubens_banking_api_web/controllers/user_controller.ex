defmodule RubensBankingApiWeb.UserController do
  use RubensBankingApiWeb, :controller

  alias RubensBankingApi.Auth
  alias RubensBankingApi.Auth.User

  action_fallback(RubensBankingApiWeb.FallbackController)

  def index(conn, _params) do
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    accounts = Auth.list_user_accounts(user_id)
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Auth.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with true <- id == user_id,
         {:ok, user} <- Auth.get_user(id) do
      conn
      |> put_status(200)
      |> render("show.json", user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with true <- id == user_id,
         {:ok, %User{} = user} <- Auth.update_user(id, user_params) do
      conn
      |> put_status(200)
      |> render("show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_id = Map.get(conn.private.plug_session, "current_user_id")

    with true <- id == user_id,
         {:ok, %User{}} <- Auth.delete_user(id) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Auth.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_status(:ok)
        |> put_view(RubensBankingApiWeb.UserView)
        |> render("sign_in.json", user: user)

      {:error, message} ->
        conn
        |> delete_session(:current_user_id)
        |> put_status(:unauthorized)
        |> put_view(RubensBankingApiWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end
end
