defmodule RubensBankingApiWeb.AccountTransactionControllerTest do
  use RubensBankingApiWeb.ConnCase

  import RubensBankingApi.Factories.Factory

  alias RubensBankingApi.Auth

  alias Plug.Test

  @current_user_attrs %{
    email: "some current user email",
    is_active: true,
    password: "some current user password"
  }

  def fixture(:current_user) do
    {:ok, current_user} = Auth.create_user(@current_user_attrs)
    current_user
  end

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user(conn)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: current_user}
  end

  describe "get_report/1" do
    test "successfully generates report with one transaction", %{conn: conn} do
      account_transaction_1 =
        insert(:account_transaction,
          transaction_starter_account_id: 1500,
          transaction_type: "open account",
          amount: "100000"
        )

      params = %{account_id: "1500", report_period: "day"}

      response =
        conn
        |> post(account_transaction_path(conn, :get_report, params))
        |> json_response(201)

      assert %{
               "data" => [
                 %{
                   "amount" => MoneyHelper.convert_amount(account_transaction_1.amount),
                   "id" => account_transaction_1.id,
                   "receiver_account_id" => account_transaction_1.receiver_account_id,
                   "transaction_starter_account_id" =>
                     account_transaction_1.transaction_starter_account_id,
                   "transaction_type" => account_transaction_1.transaction_type
                 }
               ]
             } == response
    end

    test "successfully generates report when transaction does not have amount", %{conn: conn} do
      account_transaction_1 =
        insert(:account_transaction,
          transaction_starter_account_id: 1500,
          transaction_type: "close account",
          amount: nil
        )

      params = %{account_id: "1500", report_period: "day"}

      response =
        conn
        |> post(account_transaction_path(conn, :get_report, params))
        |> json_response(201)

      assert %{
               "data" => [
                 %{
                   "id" => account_transaction_1.id,
                   "receiver_account_id" => account_transaction_1.receiver_account_id,
                   "transaction_starter_account_id" =>
                     account_transaction_1.transaction_starter_account_id,
                   "transaction_type" => account_transaction_1.transaction_type
                 }
               ]
             } == response
    end

    test "successfully generates report with multiple transactions", %{conn: conn} do
      account_transaction_1 =
        insert(:account_transaction,
          transaction_starter_account_id: 1500,
          transaction_type: "open account",
          amount: "100000"
        )

      account_transaction_2 =
        insert(:account_transaction,
          transaction_starter_account_id: 1500,
          transaction_type: "withdraw",
          amount: "25000"
        )

      account_transaction_3 =
        insert(:account_transaction,
          receiver_account_id: 1500,
          transaction_type: "transfer_money",
          amount: "10000"
        )

      params = %{account_id: "1500", report_period: "day"}

      response =
        conn
        |> post(account_transaction_path(conn, :get_report, params))
        |> json_response(201)

      assert %{
               "data" => [
                 %{
                   "amount" => MoneyHelper.convert_amount(account_transaction_1.amount),
                   "id" => account_transaction_1.id,
                   "receiver_account_id" => account_transaction_1.receiver_account_id,
                   "transaction_starter_account_id" =>
                     account_transaction_1.transaction_starter_account_id,
                   "transaction_type" => account_transaction_1.transaction_type
                 },
                 %{
                   "amount" => MoneyHelper.convert_amount(account_transaction_2.amount),
                   "id" => account_transaction_2.id,
                   "receiver_account_id" => account_transaction_2.receiver_account_id,
                   "transaction_starter_account_id" =>
                     account_transaction_2.transaction_starter_account_id,
                   "transaction_type" => account_transaction_2.transaction_type
                 },
                 %{
                   "amount" => MoneyHelper.convert_amount(account_transaction_3.amount),
                   "id" => account_transaction_3.id,
                   "receiver_account_id" => account_transaction_3.receiver_account_id,
                   "transaction_starter_account_id" =>
                     account_transaction_3.transaction_starter_account_id,
                   "transaction_type" => account_transaction_3.transaction_type
                 }
               ]
             } == response
    end
  end

  defp setup_current_user(conn) do
    current_user = fixture(:current_user)

    {:ok,
     conn: Test.init_test_session(conn, current_user_id: current_user.id),
     current_user: current_user}
  end
end
