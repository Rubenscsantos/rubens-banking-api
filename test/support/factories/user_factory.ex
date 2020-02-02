defmodule RubensBankingApi.Factories.UserFactory do
  @moduledoc """
    Factory for User
  """
  defmacro __using__(_opts) do
    quote do
      alias RubensBankingApi.Auth.User
      alias RubensBankingApi.Factories.Factory

      def user_factory do
        %User{
          email: "example@gmail.com",
          is_active: true,
          password_hash: "kjansdkjnASd849u23rn394fn3984nmf"
        }
      end
    end
  end
end
