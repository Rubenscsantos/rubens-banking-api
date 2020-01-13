defmodule RubensBankingApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :rubens_banking_api

  plug(Plug.RequestId)
  plug(Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Poison)
  plug(Plug.Logger)

  plug(Plug.Session,
    store: :cookie,
    key: "_rubens_banking_api_key",
    signing_salt: "ZOc+gbvY"
  )

  plug(RubensBankingApiWeb.Router)

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """

  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
