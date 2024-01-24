defmodule PlateSlateWeb.Schema.Query.UpdateMenuItemTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Repo, Menu}
  import Ecto.Query

  setup do
    PlateSlate.Seeds.run()

    item_id =
      from(t in Menu.Item, where: t.name == "French Fries")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string

    {:ok, item_id: item_id}
  end

  @query """
  mutation($id: ID!, $menuItem: MenuItemInputUpdate!) {
    updateMenuItem(id: $id, input: $menuItem) {
      errors { key message }
      menuItem {
        name
        price
      }
    }
  }
  """

  test "updateMenuItem field updates an item", %{item_id: item_id} do
    menu_item = %{
      "name" => "French Fries Deluxe",
      "price" => "3.5"
    }

    response =
      post build_conn(), "/api",
        query: @query,
        variables: %{"id" => item_id, "menuItem" => menu_item}

    assert json_response(response, 200) == %{
             "data" => %{
               "updateMenuItem" => %{
                 "errors" => nil,
                 "menuItem" => %{
                   "name" => menu_item["name"],
                   "price" => menu_item["price"]
                 }
               }
             }
           }
  end
end
