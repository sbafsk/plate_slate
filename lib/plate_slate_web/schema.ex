defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Resolvers

  import_types(__MODULE__.MenuTypes)

  query do
    @desc "List of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg(:filter, :menu_item_filter)
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.menu_items/3)
    end

    @desc "List of available categories"
    field :categories, list_of(:category) do
      arg(:name, :string)
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.categories/3)
    end

    @desc "Search for menu items or categories"
    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  scalar :date do
    parse(fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end)

    serialize(fn date ->
      Date.to_iso8601(date)
    end)
  end
end
