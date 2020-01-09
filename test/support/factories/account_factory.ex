defmodule RubensBankingApi.AccountFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias RubensBankingApi.Accounts.Account

      def account_factory do
        %Account{
          balance: 100_000,
          owner_name: "Rubens",
          document_type: "RG",
          document: "1234554321",
          status: "open"
        }
      end
    end
  end
end