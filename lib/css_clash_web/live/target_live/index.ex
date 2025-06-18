defmodule CssClashWeb.TargetLive.Index do
  use CssClashWeb, :live_view

  alias CssClash.Targets

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Targets")
      |> stream(:targets, Targets.list_targets())

    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    target = Targets.get_target!(id)
    {:ok, _} = Targets.delete_target(target)

    {:noreply, stream_delete(socket, :targets, target)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Targets
        <:actions>
          <.button variant="primary" navigate={~p"/targets/new"}>
            <.icon name="hero-plus" /> New Target
          </.button>
        </:actions>
      </.header>

      <.table
        id="targets"
        rows={@streams.targets}
        row_click={fn {_id, target} -> JS.navigate(~p"/targets/#{target}") end}
      >
        <:col :let={{_id, target}} label="Name">{target.name}</:col>
        <:col :let={{_id, target}} label="Image data">{target.image_data}</:col>
        <:col :let={{_id, target}} label="Colors">{target.colors}</:col>
        <:action :let={{_id, target}}>
          <div class="sr-only">
            <.link navigate={~p"/targets/#{target}"}>Show</.link>
          </div>
          <.link navigate={~p"/targets/#{target}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, target}}>
          <.link
            phx-click={JS.push("delete", value: %{id: target.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end
end
