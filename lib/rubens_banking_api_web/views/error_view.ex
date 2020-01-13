defmodule RubensBankingApiWeb.ErrorView do
  use RubensBankingApiWeb, :view

  alias Phoenix.Controller
  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  def render("errors.json", %{errors: errors}) when is_list(errors) do
    parsed_errors =
      case Keyword.keyword?(errors) do
        true -> convert_keyword_to_map(errors)
        false -> errors
      end

    %{errors: parsed_errors}
  end

  def render("errors.json", %{errors: errors}) do
    %{errors: errors}
  end

  def render("401.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Controller.status_message_from_template(template)}}
  end

  defp convert_keyword_to_map(keyword) do
    Enum.reduce(keyword, %{}, fn {key, value}, acc -> Map.put(acc, key, value) end)
  end
end
