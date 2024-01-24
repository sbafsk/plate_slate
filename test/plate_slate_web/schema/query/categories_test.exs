defmodule PlateSlateWeb.Schema.Query.CategoriesTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    categories{
      name
    }
  }
  """

  test "returns list of categories" do
    response = get build_conn(), "/api", query: @query

    assert json_response(response, 200) == %{
             "data" => %{
               "categories" => [
                 %{"name" => "Beverages"},
                 %{"name" => "Sandwiches"},
                 %{"name" => "Sides"}
               ]
             }
           }
  end
end
