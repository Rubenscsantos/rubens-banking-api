defmodule RubensBankingApi.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: RubensBankingApi.Repo
  use RubensBankingApi.AccountFactory
  use RubensBankingApi.AccountTransactionFactory
end
