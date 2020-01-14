defmodule RubensBankingApiWeb.AccountControllerTest do
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

  describe "create/2" do
    test "successfully creates an account", %{conn: conn} do
      params = %{document: "3984753985", document_type: "RG", owner_name: "Tupac"}

      response =
        conn
        |> post(account_path(conn, :create, params))
        |> json_response(201)

      assert %{
               "data" => %{
                 "document" => document,
                 "document_type" => document_type,
                 "id" => account_id,
                 "owner_name" => owner_name,
                 "status" => status
               }
             } = response

      response = conn |> get(account_path(conn, :show, account_id)) |> json_response(200)

      assert %{
               "data" => %{
                 "document" => ^document,
                 "document_type" => ^document_type,
                 "id" => ^account_id,
                 "owner_name" => ^owner_name,
                 "status" => ^status
               }
             } = response
    end
  end

  describe "show/2" do
    test "given an existing id, return the correct account", %{conn: conn} do
      %{id: account_id, balance: balance} = account = insert(:account)

      converted_balance = MoneyHelper.convert_amount(balance)

      response =
        conn
        |> get(account_path(conn, :show, account_id))
        |> json_response(200)

      assert %{
               "data" => %{
                 "document" => account.document,
                 "document_type" => account.document_type,
                 "id" => account.id,
                 "owner_name" => account.owner_name,
                 "balance" => converted_balance,
                 "status" => account.status
               }
             } == response
    end
  end

  @moduletag :capture_log
  describe "close_account/2" do
    test "given an existing id, closes an open account", %{conn: conn} do
      %{id: account_id} = insert(:account, status: "open")

      response =
        conn
        |> post(account_path(conn, :close, account_id))
        |> json_response(201)

      assert %{
               "data" => %{
                 "document" => document,
                 "document_type" => document_type,
                 "id" => account_id,
                 "owner_name" => owner_name,
                 "status" => "closed"
               }
             } = response

      response = conn |> get(account_path(conn, :show, account_id)) |> json_response(200)

      assert %{
               "data" => %{
                 "document" => ^document,
                 "document_type" => ^document_type,
                 "id" => ^account_id,
                 "owner_name" => ^owner_name,
                 "status" => "closed"
               }
             } = response
    end

    test "returns error when account was already closed", %{conn: conn} do
      %{id: account_id} = insert(:account, status: "closed")

      response =
        conn
        |> post(account_path(conn, :close, account_id))
        |> json_response(400)

      assert %{"errors" => "account_is_already_closed"} == response
    end
  end

  describe "withdraw/2" do
    test "successfully withdraws money from account", %{conn: conn} do
      %{id: account_id, balance: balance} = insert(:account)

      params = %{account_id: account_id, amount: 25_000}

      response =
        conn
        |> post(account_path(conn, :withdraw, params))
        |> json_response(201)

      assert %{
               "data" => %{
                 "document" => document,
                 "document_type" => document_type,
                 "id" => ^account_id,
                 "owner_name" => owner_name,
                 "balance" => amount,
                 "status" => status
               }
             } = response

      response = conn |> get(account_path(conn, :show, account_id)) |> json_response(200)

      assert %{
               "data" => %{
                 "document" => ^document,
                 "document_type" => ^document_type,
                 "id" => ^account_id,
                 "owner_name" => ^owner_name,
                 "balance" => ^amount,
                 "status" => ^status
               }
             } = response

      refute balance == amount
    end

    test "returns error when account was already closed", %{conn: conn} do
      %{id: account_id} = insert(:account, status: "closed")

      params = %{account_id: account_id, amount: 25_000}

      response =
        conn
        |> post(account_path(conn, :withdraw, params))
        |> json_response(400)

      assert %{"errors" => "cannot_update_closed_account"} == response
    end
  end

  describe "transfer_money/2" do
    test "successfully transfer money from the transaction starter account to the receiver account",
         %{conn: conn} do
      %{id: transaction_starter_id} = insert(:account)
      %{id: receiver_account_id} = insert(:account)

      params = %{
        transaction_starter_account_id: transaction_starter_id,
        receiver_account_id: receiver_account_id,
        amount: 25_000
      }

      converted_amount = MoneyHelper.convert_amount(25_000)

      response =
        conn
        |> post(account_path(conn, :transfer_money, params))
        |> json_response(201)

      assert %{
               "data" => %{
                 "amount" => ^converted_amount,
                 "receiver_account_id" => ^receiver_account_id,
                 "transaction_starter_account_id" => ^transaction_starter_id,
                 "transaction_type" => "transfer money"
               }
             } = response
    end

    @moduletag :capture_log
    test "returns error when transaction starter account does not have enough money", %{
      conn: conn
    } do
      %{id: transaction_starter_id} = insert(:account, balance: 24_999)
      %{id: receiver_account_id} = insert(:account)

      params = %{
        transaction_starter_account_id: transaction_starter_id,
        receiver_account_id: receiver_account_id,
        amount: 25_000
      }

      response =
        conn
        |> post(account_path(conn, :transfer_money, params))
        |> json_response(422)

      assert %{"errors" => %{"balance" => ["must be greater than or equal to 0"]}} == response
    end

    test "returns error when account was already closed", %{conn: conn} do
      %{id: transaction_starter_account_id} = insert(:account, status: "closed")
      %{id: receiver_account_id} = insert(:account)

      params = %{
        transaction_starter_account_id: transaction_starter_account_id,
        receiver_account_id: receiver_account_id,
        amount: 25_000
      }

      response =
        conn
        |> post(account_path(conn, :transfer_money, params))
        |> json_response(400)

      assert %{"errors" => "cannot_update_closed_account"} == response
    end
  end

  defp setup_current_user(conn) do
    current_user = fixture(:current_user)

    {:ok,
     conn: Test.init_test_session(conn, current_user_id: current_user.id),
     current_user: current_user}
  end
end
