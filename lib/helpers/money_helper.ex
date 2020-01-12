defmodule RubensBankingApi.Helpers.MoneyHelper do
  @moduledoc """
    This module helps when displaying amounts for the user to see
  """
  def convert_amount(amount) when is_integer(amount) do
    Integer.to_string(amount) |> convert_amount()
  end

  def convert_amount(amount) do
    converted_amount =
      String.split(amount, "", trim: true) |> List.insert_at(-3, ",") |> Enum.join()

    "R$" <> converted_amount
  end
end
