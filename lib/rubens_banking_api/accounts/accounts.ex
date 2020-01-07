defmodule RubensBankingApi.Accounts do
  @moduledoc false

  use Ecto.Schema

  schema "accounts" do
    field(:account_id, :string)
    field(:amount, :integer)
    field(:document_type, :string)
    field(:document, :string)
    field(:status, :string)

    timestamps()
  end
end
