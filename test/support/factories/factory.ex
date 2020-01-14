defmodule RubensBankingApi.Factories.Factory do
  @moduledoc """
   Defines factories in order to help testing
  """
  use ExMachina.Ecto, repo: RubensBankingApi.Repo
  use RubensBankingApi.Factories.AccountFactory
  use RubensBankingApi.Factories.AccountTransactionFactory
end
