defmodule RubensBankingApi.Auth do
  @moduledoc """
    Abstraction for UsersRepository
  """
  alias RubensBankingApi.Auth.UsersRepository

  alias RubensBankingApi.Auth.User

  @spec list_users() :: list(%User{})
  def list_users do
    UsersRepository.get_all()
  end

  @spec list_user_accounts(id :: String.t()) :: list(accounts :: String.t())
  def list_user_accounts(id) do
    with {:ok, user} <- get_user(id) do
      user.accounts
    end
  end

  @spec get_user(id :: String.t()) ::
          {:error, :user_not_found} | {:ok, User.t()}
  def get_user(id) when not is_nil(id) do
    UsersRepository.get(id)
  end

  def get_user(_id), do: {:error, :user_not_found}

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

  @spec authenticate_user(email :: String.t(), password :: String.t()) ::
          {:ok, User.t()} | {:error, reason :: any()}
  def authenticate_user(email, password) do
    UsersRepository.authenticate(email, password)
  end

  @spec authorize_operation(id :: String.t(), account_code :: String.t()) ::
          {:ok, :authorized_operation} | {:error, :unauthorized_operation}
  def authorize_operation(id, account_code) do
    with {:ok, user} <- get_user(id),
         accounts <- Map.get(user, :accounts) do
      case Enum.find(accounts, fn account -> account.account_code == account_code end) do
        nil -> {:error, :unauthorized_operation}
        _account -> {:ok, :authorized_operation}
      end
    end
  end
end
