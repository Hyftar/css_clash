defmodule CssClashWeb.TargetLive.Show do
  use CssClashWeb, :live_view

  alias CssClash.Targets

  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign(target: Targets.get_target!(id))

    {:ok, socket}
  end

  def handle_event("copied", %{"color" => color}, socket) do
    socket =
      socket
      |> put_flash(:info, dgettext("game_display", "color_copied_to_clipboard", color: color))

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.button
        id="confetti-button"
        variant="primary"
        phx-click={JS.dispatch("css_clash:confetti")}
        phx-hook="ConfettiHook"
      >
        Confettis! 🎉
      </.button>
      <.live_component
        id="game-display-container"
        module={CssClashWeb.Components.TargetDisplay}
        target={@target}
        current_user={@current_scope.user}
      />
    </Layouts.app>
    """
  end
end
