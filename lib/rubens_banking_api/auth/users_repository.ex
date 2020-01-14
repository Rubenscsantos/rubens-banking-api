defmodule RubensBankingApi.Auth.UsersRepository do
  @moduledoc """
    Repository module to access users database
  """

  import Ecto.Query, warn: false
  alias RubensBankingApi.Auth.User
  alias RubensBankingApi.Repo

  import Ecto.Query

  @spec get_all() :: list(%User{})
  def get_all do
    Repo.all(User)
  end

  @spec get(id :: term()) ::
          {:ok, %User{}} | {:error, :user_not_found} | {:error, reason :: term()}
  def get(id) do
    query = from(u in User, where: u.id == ^id)

    case Repo.one(query) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete(%User{} = user) do
    Repo.delete(user)
  end

  def change(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate(email, password) do
    query = from(u in User, where: u.email == ^email)
    query |> Repo.one() |> verify_password(password)
  end

  defp verify_password(nil, _) do
    # Perform a dummy check to make user enumeration more difficult
    Argon2.no_user_verify()
    {:error, "Wrong email or password"}
  end

  defp verify_password(user, password) do
    if Argon2.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, "Wrong email or password"}
    end
  end
end
