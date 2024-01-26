defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def create_item(_, %{input: params}, _) do
    with {:ok, menu_item} <- Menu.create_item(params) do
      {:ok, %{menu_item: menu_item}}
    end
  end

  def update_item(_, %{id: id, input: params}, _) do
    with {:ok, menu_item} <- Menu.update_item(Menu.get_item!(id), params) do
      {:ok, %{menu_item: menu_item}}
    end
  end

  def categories(_, args, _) do
    {:ok, Menu.list_categories(args)}
  end

  def items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, PlateSlate.Repo.all(query)}
  end

  def category_for_item(menu_item, _, _) do
    batch({PlateSlate.Menu, :categories_by_id}, menu_item.category_id, fn
      categories ->
        {:ok, Map.get(categories, menu_item.category_id)}
    end)
    |> IO.inspect(label: "======= INSPECTING =======")
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end
end
