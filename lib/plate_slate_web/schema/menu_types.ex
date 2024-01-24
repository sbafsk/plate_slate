defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers

  object :menu_item do
    interfaces([:search_result])
    field :id, :id
    field :name, :string
    field :description, :string
    field :added_on, :date
    # field :price, :float
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    field :name, :string
    field :category, :string
    field :tag, :string
    field :priced_above, :float
    field :priced_below, :float
    field :added_before, :date
    field :added_after, :date
  end
  interface :search_result do
    field :name, :string

    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ ->
        :menu_item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end)
  end
end
