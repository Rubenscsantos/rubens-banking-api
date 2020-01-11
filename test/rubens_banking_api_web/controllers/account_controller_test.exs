defmodule RubensBankingApiWeb.AccountControllerTest do
  use RubensBankingApiWeb.ConnCase

  import RubensBankingApi.Factories.Factory

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
      %{id: account_id} = account = insert(:account)

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
                 "status" => account.status
               }
             } == response
    end
  end

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

    # test "returns error when account was already closed", %{conn: conn} do
    #   %{id: account_id} = insert(:account, status: "closed")

    #   response =
    #     conn
    #     |> post(account_path(conn, :close, account_id))
    #     |> json_response(500)

    #   assert "" == response
    # end
  end

  # describe "withdraw/2" do
  #   test "successfully withdraws money from account", %{conn: conn} do
  #     %{id: account_id, balance: balance} = insert(:account)
  #     # params = %{"account_id" => account_id, "amount" => 25000}

  #     response =
  #       conn
  #       |> post(account_path(conn, :withdraw, %{account_id: account_id, amount: 25_000}))
  #       |> json_response(201)

  #     assert %{
  #              "data" => %{
  #                "document" => document,
  #                "document_type" => document_type,
  #                "id" => ^account_id,
  #                "owner_name" => owner_name,
  #                "balance" => amount,
  #                "status" => status
  #              }
  #            } = response

  #     response = conn |> get(account_path(conn, :show, account_id)) |> json_response(200)

  #     assert %{
  #              "data" => %{
  #                "document" => ^document,
  #                "document_type" => ^document_type,
  #                "id" => ^account_id,
  #                "owner_name" => ^owner_name,
  #                "balance" => ^amount,
  #                "status" => ^status
  #              }
  #            } = response

  #     refute balance == amount
  #   end
  # end
end
