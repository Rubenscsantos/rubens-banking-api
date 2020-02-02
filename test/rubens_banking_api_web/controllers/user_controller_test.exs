defmodule RubensBankingApiWeb.UserControllerTest do
  use RubensBankingApiWeb.ConnCase

  alias RubensBankingApi.Auth
  alias RubensBankingApi.Auth.User

  import RubensBankingApi.Factories.Factory

  alias Plug.Test

  @create_attrs %{email: "some email", password: "some password"}
  @update_attrs %{
    email: "some updated email",
    is_active: false,
    password: "some updated password"
  }
  @invalid_attrs %{email: nil, is_active: nil, password: nil}
  @current_user_attrs %{
    email: "some current user email",
    is_active: true,
    password: "some current user password"
  }

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_attrs)
    user
  end

  def fixture(:current_user) do
    {:ok, current_user} = Auth.create_user(@current_user_attrs)
    current_user
  end

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user(conn)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: current_user}
  end

  describe "index" do
    test "lists all of current user's accounts", %{conn: conn, current_user: current_user} do
      %{account_code: account_code_1, document: document_1} =
        insert(:account, user_id: current_user.id)

      %{account_code: account_code_2, document: document_2} =
        insert(:account, user_id: current_user.id)

      conn = get(conn, user_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "account_code" => account_code_2,
                 "balance" => 100_000,
                 "document" => document_2,
                 "document_type" => "RG",
                 "owner_name" => "Rubens",
                 "status" => "open"
               },
               %{
                 "account_code" => account_code_1,
                 "balance" => 100_000,
                 "document" => document_1,
                 "document_type" => "RG",
                 "owner_name" => "Rubens",
                 "status" => "open"
               }
             ]
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn =
        post(
          conn,
          user_path(conn, :create),
          user: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn =
        post(
          conn,
          user_path(conn, :sign_in, %{
            email: @create_attrs.email,
            password: @create_attrs.password
          })
        )

      conn = get(conn, user_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "email" => "some email",
               "is_active" => false
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "get user" do
    setup [:create_user]

    test "returns user", %{conn: conn, current_user: %{id: id} = current_user} do
      conn = get(conn, user_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "email" => current_user.email,
               "is_active" => current_user.is_active
             }
    end

    test "returns unauthorized when user cannot operate on given user_id", %{
      conn: conn,
      user: %{id: id}
    } do
      conn = get(conn, user_path(conn, :show, id))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, current_user: %User{id: id} = user} do
      conn = put(conn, user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, user_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "email" => "some updated email",
               "is_active" => false
             }
    end

    test "renders errors when data is invalid", %{conn: conn, current_user: user} do
      conn = put(conn, user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns unauthorized when user cannot operate on given user_id", %{
      conn: conn,
      user: user
    } do
      conn = put(conn, user_path(conn, :update, user), user: @update_attrs)

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, current_user: %{id: user_id} = current_user} do
      conn = get(conn, user_path(conn, :show, user_id))

      assert json_response(conn, 200)["data"] == %{
               "id" => user_id,
               "email" => current_user.email,
               "is_active" => current_user.is_active
             }

      conn = delete(conn, user_path(conn, :delete, user_id))

      conn = get(conn, user_path(conn, :show, user_id))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthenticated user"}}
    end

    test "returns error in case user has accounts ", %{conn: conn, current_user: %{id: user_id}} do
      insert(:account, user_id: user_id)
      conn = delete(conn, user_path(conn, :delete, user_id))
      assert json_response(conn, 400) == %{"errors" => "user_has_accounts"}
    end

    test "returns unauthorized when user cannot operate on given user_id", %{
      conn: conn,
      user: %{id: user_id}
    } do
      conn = delete(conn, user_path(conn, :delete, user_id))
      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
    end
  end

  describe "sign_in user" do
    test "renders user when user credentials are good", %{conn: conn, current_user: current_user} do
      conn =
        post(
          conn,
          user_path(conn, :sign_in, %{
            email: current_user.email,
            password: @current_user_attrs.password
          })
        )

      response = json_response(conn, 200)

      assert response["data"] == %{
               "user" => %{
                 "id" => current_user.id,
                 "email" => current_user.email
               }
             }
    end

    test "renders errors when user credentials are bad", %{conn: conn} do
      conn = post(conn, user_path(conn, :sign_in, %{email: "non-existent email", password: ""}))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Wrong email or password"}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp setup_current_user(conn) do
    current_user = fixture(:current_user)

    {:ok,
     conn: Test.init_test_session(conn, current_user_id: current_user.id),
     current_user: current_user}
  end
end
