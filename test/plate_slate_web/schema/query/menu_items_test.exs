defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    menuItems {
      name
    }
  }
  """

  test "menuItems field returns menu items" do
    response = get build_conn(), "/api", query: @query

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Bánh mì"},
                 %{"name" => "Chocolate Milkshake"},
                 %{"name" => "Croque Monsieur"},
                 %{"name" => "French Fries"},
                 %{"name" => "Lemonade"},
                 %{"name" => "Masala Chai"},
                 %{"name" => "Muffuletta"},
                 %{"name" => "Papadum"},
                 %{"name" => "Pasta Salad"},
                 %{"name" => "Reuben"},
                 %{"name" => "Soft Drink"},
                 %{"name" => "Vada Pav"},
                 %{"name" => "Vanilla Milkshake"},
                 %{"name" => "Water"}
               ]
             }
           }
  end

  @query """
  {
    menuItems(filter: {name: "reu"}) {
      name
    }
  }
  """

  test "menuItems field returns menu items filtered by name" do
    respose = get(build_conn(), "/api", query: @query)

    assert json_response(respose, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
  {
    menuItems(filter: {name: 123}) {
      name
    }
  }
  """

  test "menuItems field returns errors when using a bad value" do
    respose = get(build_conn(), "/api", query: @query)

    assert %{"errors" => [%{"message" => message}]} = json_response(respose, 200)

    assert String.contains?(message, "Argument \"filter\" has invalid value {name: 123}.")
  end

  @query """
  query ($term: MenuItemFilter!){
    menuItems(filter: $term) {
      name
    }
  }
  """

  @variables %{"term" => %{"name" => "reu"}}

  test "menuItems field filters by name when using a variable" do
    respose = get(build_conn(), "/api", query: @query, variables: @variables)

    assert json_response(respose, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
  query($order: SortOrder!){
    menuItems(order: $order) {
      name
    }
  }
  """

  @variables %{"order" => "DESC"}

  test "menuItems field items descending using literals" do
    respose = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Water"} | _
               ]
             }
           } = json_response(respose, 200)
  end

  @query """
  query($filter: MenuItemFilter!){
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{"category" => "Sandwiches", "tag" => "Vegetarian"}}
  test "menuItems field returns menuItems, filtering with a variable" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
           } == json_response(response, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      addedOn
    }
  }
  """

  @variables %{filter: %{"addedBefore" => "2017-01-20"}}

  test "menuItem filtered by custom scalar" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")

    %PlateSlate.Menu.Item{
      name: "Garlic Fries",
      added_on: ~D[2017-01-01],
      price: 2.50,
      category: sides
    }
    |> PlateSlate.Repo.insert!()

    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{"data" => %{"menuItems" => [%{"name" => "Garlic Fries", "addedOn" => "2017-01-01"}]}} ==
             json_response(response, 200)
  end

  @variables %{filter: %{"addedBefore" => "not-a-date"}}

  test "menuItem filtered by custom scalar with error" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "errors" => [
               %{"message" => message}
             ]
           } = json_response(response, 200)

    expected = """
    Argument "filter" has invalid value $filter.
    In field "addedBefore": Expected type "Date", found "not-a-date".\
    """

    assert expected == message
  end

  @query """
  query($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      price
    }
  }
  """

  @variables %{"filter" => %{"priced_below" => "1.25"}}

  test "menuItem filtered by priced below" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Lemonade", "price" => "1.25"},
                 %{"name" => "Papadum", "price" => "1.25"},
                 %{"name" => "Water", "price" => "0"}
               ]
             }
           } ==
             json_response(response, 200)
  end
end
