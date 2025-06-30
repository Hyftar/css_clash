defmodule CssClashWeb.TargetLive.Index do
  use CssClashWeb, :live_view

  alias CssClash.Targets

  import CssClashWeb.Components.Target.TargetImage

  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:targets, Targets.list_targets(socket.assigns.current_scope.user.id))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <h1 class="text-lg mx-12 my-8">{dgettext("targets", "page_title")}</h1>
      <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 mx-8">
        <.link
          :for={{item_id, target} <- @streams.targets}
          id={item_id}
          navigate={~p"/targets/#{target.id}"}
          class="card card-border bg-base-200 transition-[scale] duration-100 hover:scale-105"
        >
          <figure class="mt-2 mx-2">
            <.target_image
              target={target}
              width={400}
              height={400}
              class="rounded-md"
              alt={"target-#{target.id}-image"}
            />
          </figure>
          <div class="card-body">
            <h3 class="card-title flex justify-between">
              {target.name}
              <span class="text-xs badge badge-neutral font-mono">
                {target.inserted_at |> format_timestamp_to_local_date()}
              </span>
            </h3>
            <div>
              <h3 class="mb-2 text-md font-bold text-neutral/80">
                {dgettext("targets", "your_score")}
              </h3>
              <div class={
                classes([
                  "text-neutral-content font-mono text-lg p-4",
                  target.user_max_score != nil && "bg-accent badge text-accent-content"
                ])
              }>
                <%= if target.user_max_score do %>
                  {(target.user_max_score * 100) |> trunc()}%
                <% else %>
                  {dgettext("targets", "not_yet_tried")}
                <% end %>
              </div>
            </div>
          </div>
        </.link>
      </div>
    </Layouts.app>
    """
  end
end
