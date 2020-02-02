defmodule RubensBankingApi.Factories.Factory do
  @moduledoc """
   Defines factories in order to help testing
  """
  use ExMachina.Ecto, repo: RubensBankingApi.Repo
  use RubensBankingApi.Factories.{AccountFactory, AccountTransactionFactory, UserFactory}

  def generate_account_code do
    10_000..99_999
    |> Enum.random()
    |> to_string()
  end

  def generate_account_document do
    10_000_000_000..99_999_999_999
    |> Enum.random()
    |> to_string()
  end
end
