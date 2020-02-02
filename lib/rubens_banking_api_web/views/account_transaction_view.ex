defmodule RubensBankingApiWeb.AccountTransactionView do
  use RubensBankingApiWeb, :view

  def render("show.json", %{account_transaction: account_transactions})
      when is_list(account_transactions) do
    %{data: render_many(account_transactions, __MODULE__, "account_transaction.json")}
  end

  def render("show.json", %{account_transaction: account_transaction}) do
    %{data: render("account_transaction.json", %{account_transaction: account_transaction})}
  end

  def render("account_transaction.json", %{
        account_transaction: %{amount: amount} = account_transaction
      })
      when not is_nil(amount) do
    %{
      id: account_transaction.id,
      transaction_starter_account_code: account_transaction.transaction_starter_account_code,
      receiver_account_code: account_transaction.receiver_account_code,
      transaction_type: account_transaction.transaction_type,
      amount: amount
    }
  end

  def render("account_transaction.json", %{account_transaction: account_transaction}) do
    %{
      id: account_transaction.id,
      transaction_starter_account_code: account_transaction.transaction_starter_account_code,
      receiver_account_code: account_transaction.receiver_account_code,
      transaction_type: account_transaction.transaction_type
    }
  end
end
