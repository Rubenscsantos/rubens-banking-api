defmodule RubensBankingApiWeb.AccountView do
  use RubensBankingApiWeb, :view

  import RubensBankingApiWeb.MoneyHelper

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
      id: account.id,
      owner_name: account.owner_name,
      balance: convert_amount(account.balance),
      document: account.document,
      document_type: account.document_type,
      status: account.status
    }
  end

  def render("account_transaction.json", %{account_transaction: account_transaction}) do
    %{
      id: account_transaction.id,
      transaction_starter_account_id: account_transaction.transaction_starter_account_id,
      receiver_account_id: account_transaction.receiver_account_id,
      transaction_type: account_transaction.transaction_type,
      amount: convert_amount(account_transaction.amount)
    }
  end
end
