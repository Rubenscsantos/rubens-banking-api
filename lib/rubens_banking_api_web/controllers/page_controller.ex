defmodule RubensBankingApiWeb.PageController do
  use RubensBankingApiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
