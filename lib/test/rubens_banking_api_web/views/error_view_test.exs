defmodule RubensBankingApiWeb.ErrorViewTest do
  use RubensBankingApiWeb.ConnCase, async: true

  alias RubensBankingApiWeb.ErrorView

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert render(ErrorView, "500.json", []) == %{errors: %{detail: "Internal Server Error"}}
  end

  describe "errors.json" do
    test "Render binary error" do
      assert render(ErrorView, "errors.json", %{errors: "binary"}) == %{errors: "binary"}
    end

    test "Render map of errors" do
      assert render(ErrorView, "errors.json", %{errors: %{error1: "error_1", error2: "error_1"}}) ==
               %{errors: %{error1: "error_1", error2: "error_1"}}
    end
  end
end
