defmodule RubensBankingApi.AccountTransactions.AccountTransactionsRepository do
  alias RubensBankingApi.AccountTransactions.AccountTransaction
  alias RubensBankingApi.Repo

  import Ecto.Query

  @spec create(params :: map()) :: {:ok, Account.t()} | {:error, reason :: %Ecto.Changeset{}}
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
  def generate_report(account_id, report_duration)
      when report_duration in [:day, :week, :month, :year, :total] do
    date = Date.utc_today()

    generate_query(account_id, date, report_duration)
    |> Repo.all()
    |> case do
      [] -> {:ok, []}
      payments -> {:ok, payments}
    end
  end

  def generate_report(_account_id, _report_duration), do: {:error, :invalid_report_duration}

  defp generate_query(account_id, date, :day) do
    from(a in AccountTransaction,
      where:
        a.transaction_starter_account_id == ^account_id or a.receiver_account_id == ^account_id,
      where: fragment("?::date", a.inserted_at) == ^date
    )
  end

  defp generate_query(account_id, date, :week) do
    a_week_from_today = Date.add(date, 7)

    from(a in AccountTransaction,
      where:
        a.transaction_starter_account_id == ^account_id or a.receiver_account_id == ^account_id,
      where:
        fragment("?::date", a.inserted_at) >= ^date and
          fragment("?::date", a.inserted_at) <= ^a_week_from_today
    )
  end

  defp generate_query(account_id, date, :month) do
    a_month_from_today = Date.add(date, 30)

    from(a in AccountTransaction,
      where:
        a.transaction_starter_account_id == ^account_id or a.receiver_account_id == ^account_id,
      where:
        fragment("?::date", a.inserted_at) >= ^date and
          fragment("?::date", a.inserted_at) <= ^a_month_from_today
    )
  end

  defp generate_query(account_id, date, :year) do
    a_year_from_today = Date.add(date, 365)

    from(a in AccountTransaction,
      where:
        a.transaction_starter_account_id == ^account_id or a.receiver_account_id == ^account_id,
      where:
        fragment("?::date", a.inserted_at) >= ^date and
          fragment("?::date", a.inserted_at) <= ^a_year_from_today
    )
  end

  defp generate_query(account_id, _date, :total) do
    from(a in AccountTransaction,
      where:
        a.transaction_starter_account_id == ^account_id or a.receiver_account_id == ^account_id
    )
  end
end
