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
    test "successfully generates report with one transaction", %{
      conn: conn,
      current_user: %{id: user_id}
    } do
      %{account_code: transaction_starter_account_code} = insert(:account, user_id: user_id)

      account_transaction_1 =
        insert(:account_transaction,
          transaction_starter_account_code: transaction_starter_account_code,
          transaction_type: "open account",
          amount: "100000"
        )

      params = %{account_code: transaction_starter_account_code, report_period: "day"}

      response =
        conn
        |> post(account_transaction_path(conn, :get_report, params))
        |> json_response(201)

      assert %{
               "data" => [
                 %{
                   "amount" => account_transaction_1.amount,
                   "id" => account_transaction_1.id,
                   "receiver_account_code" => account_transaction_1.receiver_account_code,
                   "transaction_starter_account_code" =>
                     account_transaction_1.transaction_starter_account_code,
                   "transaction_type" => account_transaction_1.transaction_type
                 }
               ]
             } == response
    end

    test "successfully generates report when transaction does not have amount", %{
      conn: conn,
      current_user: %{id: user_id}
    } do
      %{account_code: transaction_starter_account_code} = insert(:account, user_id: user_id)

      account_transaction_1 =
        insert(:account_transaction,
          transaction_starter_account_code: transaction_starter_account_code,
          transaction_type: "close account",
          amount: nil
        )

      params = %{account_code: transaction_starter_account_code, report_period: "day"}

      response =
        conn
        |> post(account_transaction_path(conn, :get_report, params))
        |> json_response(201)

      assert %{
               "data" => [
                 %{
                   "id" => account_transaction_1.id,
                   "receiver_account_code" => account_transaction_1.receiver_account_code,
                   "transaction_starter_account_code" =>
                     account_transaction_1.transaction_starter_account_code,
                   "transaction_type" => account_transaction_1.transaction_type
                 }
               ]
             } == response
    end

    test "successfully generates report with multiple transactions", %{
      conn: conn,
      current_user: %{id: user_id}
    } do
      %{account_code: transaction_starter_account_code} = insert(:account, user_id: user_id)

      account_transaction_1 =
        insert(:account_transaction,
          transaction_starter_account_code: transaction_starter_account_code,
          transaction_type: "open account",
          amount: "100000"
        )

      account_transaction_2 =
        insert(:account_transaction,
          transaction_starter_account_code: transaction_starter_account_code,
          transaction_type: "withdraw",
          amount: "25000"
        )

      account_transaction_3 =
        insert(:account_transaction,
          receiver_account_code: transaction_starter_account_code,
          transaction_type: "transfer_money",
          amount: "10000"
        )

      params = %{account_code: transaction_starter_account_code, report_period: "day"}

      response =
        conn
        |> post(account_transaction_path(conn, :get_report, params))
        |> json_response(201)

      assert %{
               "data" => [
                 %{
                   "amount" => account_transaction_1.amount,
                   "id" => account_transaction_1.id,
                   "receiver_account_code" => account_transaction_1.receiver_account_code,
                   "transaction_starter_account_code" =>
                     account_transaction_1.transaction_starter_account_code,
                   "transaction_type" => account_transaction_1.transaction_type
                 },
                 %{
                   "amount" => account_transaction_2.amount,
                   "id" => account_transaction_2.id,
                   "receiver_account_code" => account_transaction_2.receiver_account_code,
                   "transaction_starter_account_code" =>
                     account_transaction_2.transaction_starter_account_code,
                   "transaction_type" => account_transaction_2.transaction_type
                 },
                 %{
                   "amount" => account_transaction_3.amount,
                   "id" => account_transaction_3.id,
                   "receiver_account_code" => account_transaction_3.receiver_account_code,
                   "transaction_starter_account_code" =>
                     account_transaction_3.transaction_starter_account_code,
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
