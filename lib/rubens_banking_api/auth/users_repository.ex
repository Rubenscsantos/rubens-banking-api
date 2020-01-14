defmodule RubensBankingApi.Auth.UsersRepository do
  @moduledoc """
  The UsersRepository context.
  """

  import Ecto.Query, warn: false
  alias RubensBankingApi.Auth.User
  alias RubensBankingApi.Repo

  import Ecto.Query

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @spec get_all() :: list(%User{})
  def get_all do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  returns {:error, :user_not_found} if the User does not exist.

  ## Examples

      iex> get_user!(123)
      {:ok, %User{}}

      iex> get_user!(456)
      {:error, :user_not_found}

  """
  @spec get(id :: term()) ::
          {:ok, %User{}} | {:error, :user_not_found} | {:error, reason :: term()}
  def get(id) do
    query = from(u in User, where: u.id == ^id)

    case Repo.one(query) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create(%{field: value})
      {:ok, %User{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update(user, %{field: new_value})
      {:ok, %User{}}

      iex> update(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete(user)
      {:ok, %User{}}

      iex> delete(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change(user)
      %Ecto.Changeset{source: %User{}}

  """
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
