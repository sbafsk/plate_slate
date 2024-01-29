defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlate.Menu

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  object :menu_item do
    interfaces([:search_result])

    field :id, :id
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :added_on, :date
    field :allergy_info, list_of(:allergy_info)

    field :category, :category do
      resolve(dataloader(Menu, :category))
    end
  end

  object :menu_item_result do
    field :menu_item, :menu_item
    field :errors, list_of(:input_error)
  end

  object :category do
    interfaces([:search_result])
    field :name, :string
    field :description, :string

    field :items, list_of(:menu_item) do
      arg(:filter, :menu_item_filter)
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(dataloader(Menu, :items))
    end
  end

  object :allergy_info do
    field :allergen, :string
    field :severity, :string
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    field :name, :string
    field :category, :string
    field :tag, :string
    field :priced_above, :decimal
    field :priced_below, :decimal
    field :added_before, :date
    field :added_after, :date
  end

  input_object :menu_item_input_create do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:decimal)
    field :category_id, non_null(:id)
  end

  input_object :menu_item_input_update do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :category_id, :id
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
