defmodule CssClashWeb.Hooks.Navigation do
  @moduledoc """
  LiveView hook for handling navigation-related functionality.

  This hook tracks the current path and stores it in socket assigns
  so that layout components like the navbar can highlight the active page.
  """

  import Phoenix.Component

  def on_mount(:save_request_uri, _params, _session, socket) do
    socket =
      socket
      |> Phoenix.LiveView.attach_hook(
        :save_request_path,
        :handle_params,
        &save_request_path/3
      )

    {:cont, socket}
  end

  defp save_request_path(_params, url, socket) do
    socket =
      socket
      |> assign(current_path: URI.parse(url).path)

    {:cont, socket}
  end
end
