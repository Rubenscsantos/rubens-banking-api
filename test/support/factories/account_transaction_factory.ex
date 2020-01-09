defmodule RubensBankingApi.AccountTransactionFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias RubensBankingApi.AccountTransactions.AccountTransaction

      def account_transaction_factory do
        %AccountTransaction{
          transaction_starter_account_id: Enum.random(1..100_000),
          receiver_account_id: Enum.random(1..100_000),
          transaction_type: "transfer_money",
          amount: 100_000
        }
      end
    end
  end
end
