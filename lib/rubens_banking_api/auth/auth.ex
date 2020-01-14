defmodule RubensBankingApi.Auth do
  @moduledoc false
  alias RubensBankingApi.Auth.UsersRepository

  alias RubensBankingApi.Auth.User

  @spec list_users() :: list(%User{})
  def list_users do
    UsersRepository.get_all()
  end

  @spec get_user(id :: String.t()) ::
          {:error, :user_not_found} | {:ok, User.t()}
  def get_user(id) do
    UsersRepository.get(id)
  end

  @spec create_user(user_params :: User.t()) :: {:ok, User.t()} | {:error, reason :: any()}
  def create_user(user_params) do
    UsersRepository.create(user_params)
  end

  @spec update_user(id :: String.t(), params :: map()) ::
          {:ok, User.t()} | {:error, reason :: any()}
  def update_user(id, user_params) do
    with {:ok, user} <- get_user(id) do
      UsersRepository.update(user, user_params)
    end
  end

  @spec change_user(id :: String.t()) :: Ecto.ChangeSet.t()
  def change_user(id) do
    with {:ok, user} <- get_user(id) do
      UsersRepository.change(user)
    end
  end

  @spec delete_user(id :: String.t()) ::
          {:ok, User.t()} | {:error, reason :: any()}
  def delete_user(id) do
    with {:ok, user} <- get_user(id) do
      UsersRepository.delete(user)
    end
  end

  def authenticate_user(email, password) do
    UsersRepository.authenticate(email, password)
  end
end
