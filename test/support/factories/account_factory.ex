defmodule RubensBankingApi.Factories.AccountFactory do
  @moduledoc """
    Factory for Account
  """
  defmacro __using__(_opts) do
    quote do
      alias RubensBankingApi.Accounts.Account
      alias RubensBankingApi.Factories.Factory

      def account_factory do
        %Account{
          account_code: Factory.generate_account_code(),
          balance: 100_000,
          owner_name: "Rubens",
          document_type: "RG",
          document: Factory.generate_account_document(),
          status: "open"
        }
      end
    end
  end
end
