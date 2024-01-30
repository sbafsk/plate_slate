defmodule PlateSlateWeb.Resolvers.Menu do
  import Absinthe.Resolution.Helpers

  alias PlateSlate.Menu

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def get_item(_, %{id: id}, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Menu, Menu.Item, id)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, Menu, Menu.Item, id)}
    end)
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

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end
end
