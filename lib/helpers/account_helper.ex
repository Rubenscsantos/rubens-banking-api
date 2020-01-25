defmodule RubensBankingApi.Helpers.AccountHelper do
  @moduledoc """
  This module helps when creating accounts
  """
  def generate_account_code do
    10_000..99_999
    |> Enum.random()
    |> to_string()
  end
end
