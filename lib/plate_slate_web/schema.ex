defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Resolvers

  @desc "The list of available items on the menu"
  query do
    field :menu_items, list_of(:menu_item) do
      arg(:matching, :string)
      resolve(&Resolvers.Menu.menu_items/3)
    end
  end

  @desc "This is an item of the menu"
  object :menu_item do
    field :id, :id
    field :name, :string
    field :description, :string
    # @desc "Item's price"
    # field :price, :float
  end
end
