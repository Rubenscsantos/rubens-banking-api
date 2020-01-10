defmodule RubensBankingApi.Factories.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: RubensBankingApi.Repo
  use RubensBankingApi.Factories.AccountFactory
  use RubensBankingApi.Factories.AccountTransactionFactory
end
