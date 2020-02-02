defmodule RubensBankingApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use RubensBankingApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(RubensBankingApiWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(400)
    |> render(RubensBankingApiWeb.ErrorView, "errors.json", %{errors: reason})
  end

  def call(conn, false) do
    conn
    |> put_status(:unauthorized)
    |> put_view(RubensBankingApiWeb.ErrorView)
    |> render("401.json")
  end
end
