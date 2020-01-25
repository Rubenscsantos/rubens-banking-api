defmodule RubensBankingApi.Factories.AccountTransactionFactory do
  @moduledoc """
    Factory for AccountTransaction
  """
  defmacro __using__(_opts) do
    quote do
      alias RubensBankingApi.AccountTransactions.AccountTransaction
      alias RubensBankingApi.Factories.Factory

      def account_transaction_factory do
        %AccountTransaction{
          transaction_starter_account_code: Factory.generate_account_code(),
          receiver_account_code: Factory.generate_account_code(),
          transaction_type: "transfer money",
          amount: Enum.random(1..500_000)
        }
      end
    end
  end
end
