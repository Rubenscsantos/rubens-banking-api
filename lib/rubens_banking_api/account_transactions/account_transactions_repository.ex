defmodule RubensBankingApi.AccountTransactions.AccountTransactionsRepository do
  @moduledoc """
    Repository module to access the account_transactions database
  """
  alias RubensBankingApi.AccountTransactions.AccountTransaction
  alias RubensBankingApi.Repo

  import Ecto.Query

  @spec create(params :: map()) ::
          {:ok, AccountTransaction.t()} | {:error, reason :: %Ecto.Changeset{}}
  def create(params) do
    %AccountTransaction{}
    |> AccountTransaction.changeset(params)
    |> Repo.insert()
  end

  @spec get(id :: String.t()) ::
          {:ok, %AccountTransaction{}} | {:error, :account_transaction_not_found}
  def get(id) do
    AccountTransaction
    |> Repo.get(id)
    |> case do
      %AccountTransaction{} = account_transaction -> {:ok, account_transaction}
      nil -> {:error, :account_transaction_not_found}
    end
  end

  @spec generate_report(account_id :: String.t(), atom()) :: List.t(AccountTransaction.t())
  def generate_report(account_id, report_period)
      when report_period in [:day, :week, :month, :year, :total] do
    today = Date.utc_today()

    today
    |> generate_end_of_report_period(report_period)
    |> generate_query(account_id, today)
    |> Repo.all()
    |> case do
      [] -> {:ok, []}
      payments -> {:ok, payments}
    end
  end

  def generate_report(_account_id, _report_period), do: {:error, :invalid_report_period}

  defp generate_end_of_report_period(today, :day), do: Date.add(today, 1)
  defp generate_end_of_report_period(today, :week), do: Date.add(today, 7)
  defp generate_end_of_report_period(today, :month), do: Date.add(today, 30)
  defp generate_end_of_report_period(today, :year), do: Date.add(today, 365)
  defp generate_end_of_report_period(_today, :total), do: :total

  defp generate_query(:total, account_id, _today) do
    from(a in AccountTransaction,
      where:
        a.transaction_starter_account_id == ^account_id or a.receiver_account_id == ^account_id
    )
  end

  defp generate_query(end_of_report_period, account_id, today) do
    from(a in AccountTransaction,
      where:
        a.transaction_starter_account_id == ^account_id or a.receiver_account_id == ^account_id,
      where:
        fragment("?::date", a.inserted_at) >= ^today and
          fragment("?::date", a.inserted_at) < ^end_of_report_period
    )
  end
end
