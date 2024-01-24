defmodule PlateSlateWeb.Schema.Query.CreateMenuItemTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Repo, Menu}
  import Ecto.Query

  setup do
    PlateSlate.Seeds.run()

    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string

    {:ok, category_id: category_id}
  end

  @query """
  mutation($menuItem: MenuItemInput!) {
    createMenuItem(input: $menuItem) {
      name
      description
      price
    }
  }
  """

  test "createMenuItem field creates an item", %{category_id: category_id} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "category_id" => category_id
    }

    response = post build_conn(), "/api", query: @query, variables: %{"menuItem" => menu_item}

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "name" => menu_item["name"],
                 "description" => menu_item["description"],
                 "price" => menu_item["price"]
               }
             }
           }
  end
end
