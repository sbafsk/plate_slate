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

    employee = Factory.create_user("employee")
    customer = Factory.create_user("customer")

    {:ok, category_id: category_id, employee: employee, customer: customer}
  end

  @query """
  mutation($menuItem: MenuItemInputCreate!) {
    createMenuItem(input: $menuItem) {
      errors { key message }
      menuItem {
        name
        description
        price
      }
    }
  }
  """

  test "createMenuItem field creates an item", %{
    category_id: category_id,
    employee: employee
  } do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "category_id" => category_id
    }

    response =
      post build_conn() |> auth_user(employee), "/api",
        query: @query,
        variables: %{"menuItem" => menu_item}

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "errors" => nil,
                 "menuItem" => %{
                   "name" => menu_item["name"],
                   "description" => menu_item["description"],
                   "price" => menu_item["price"]
                 }
               }
             }
           }
  end

  test "creates a menu item with an existing name fails", %{
    category_id: category_id,
    employee: employee
  } do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "category_id" => category_id
    }

    response =
      post build_conn() |> auth_user(employee), "/api",
        query: @query,
        variables: %{"menuItem" => menu_item}

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "errors" => [
                   %{"key" => "name", "message" => "has already been taken"}
                 ],
                 "menuItem" => nil
               }
             }
           }
  end

  test "must be authorized as an employee to do menu item creation", %{
    category_id: category_id,
    customer: customer
  } do
    menu_item = %{
      "name" => "Reuben Deluxe",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "category_id" => category_id
    }

    response =
      post build_conn() |> auth_user(customer), "/api",
        query: @query,
        variables: %{"menuItem" => menu_item}

    assert json_response(response, 200) == %{
             "data" => %{"createMenuItem" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "message" => "unauthorized",
                 "path" => ["createMenuItem"]
               }
             ]
           }
  end

  defp auth_user(conn, user) do
    token = PlateSlateWeb.Authentication.sign(%{role: user.role, id: user.id})
    put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
