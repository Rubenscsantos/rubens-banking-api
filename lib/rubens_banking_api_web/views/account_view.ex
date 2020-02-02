defmodule RubensBankingApiWeb.AccountView do
  use RubensBankingApiWeb, :view

  def render("show.json", %{account: account}) do
    %{data: render("account.json", %{account: account})}
  end

  def render("show.json", %{account_transaction: account_transaction}) do
    %{
      data: render("account_transaction.json", %{account_transaction: account_transaction})
    }
  end

  def render("account.json", %{account: account}) do
    %{
      account_code: account.account_code,
      owner_name: account.owner_name,
      balance: account.balance,
      document: account.document,
      document_type: account.document_type,
      status: account.status
    }
  end

  def render("account_transaction.json", %{account_transaction: account_transaction}) do
    %{
      id: account_transaction.id,
      transaction_starter_account_code: account_transaction.transaction_starter_account_code,
      receiver_account_code: account_transaction.receiver_account_code,
      transaction_type: account_transaction.transaction_type,
      amount: account_transaction.amount
    }
  end
end
