defmodule CrudWeb.ItemLive.Index do
  use CrudWeb, :live_view

  alias Crud.Product

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Items
        <:actions>
          <.button variant="primary" navigate={~p"/items/new"}>
            <.icon name="hero-plus" /> New Item
          </.button>
        </:actions>
      </.header>

      <.table
        id="items"
        rows={@streams.items}
        row_click={fn {_id, item} -> JS.navigate(~p"/items/#{item}") end}
      >
        <:col :let={{_id, item}} label="Name">{item.name}</:col>
        <:col :let={{_id, item}} label="Code">{item.code}</:col>

        <:col :let={{_id, item}} label="Category">
          <%= if item.category do %>
            <%= item.category.name %>
          <% else %>
            No category
          <% end %>
        </:col>
        <%!-- <:col :let={{_id, item}} label="Tags">
          <%= if item.tags && length(item.tags) > 0 do %>
            {Enum.map_join(item.tags, ", ", & &1.name)}
          <% else %>
            No Tags
          <% end %>
        </:col> --%>

        <:action :let={{_id, item}}>
          <div class="sr-only">
            <.link navigate={~p"/items/#{item}"}>Show</.link>
          </div>
          <.link navigate={~p"/items/#{item}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, item}}>
          <.link
            phx-click={JS.push("delete", value: %{id: item.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Items")
     |> stream(:items, list_items())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Product.get_item!(id)
    {:ok, _} = Product.delete_item(item)

    {:noreply, stream_delete(socket, :items, item)}
  end

  defp list_items() do
    Product.list_items()
  end
end
