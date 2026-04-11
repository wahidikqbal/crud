defmodule CrudWeb.ItemLive.Show do
  use CrudWeb, :live_view

  alias Crud.Product

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Item {@item.id}
        <:subtitle>This is a item record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/items"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/items/#{@item}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit item
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@item.name}</:item>
        <:item title="Code">{@item.code}</:item>
        <:item title="Category">
          <%= if @item.category do %>
            <%= @item.category.name %>
          <% else %>
            No category
          <% end %>
        </:item>
        <:item title="Tags">
          <%= if @item.tags && length(@item.tags) > 0 do %>
            {Enum.map_join(@item.tags, ", ", & &1.name)}
          <% else %>
            No Tags
          <% end %>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Item")
     |> assign(:item, Product.get_item!(id))}
  end
end
