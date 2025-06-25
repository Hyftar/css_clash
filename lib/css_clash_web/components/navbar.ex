defmodule CssClashWeb.Components.Navbar do
  use CssClashWeb, :html

  import CssClashWeb.Layouts

  import Tails

  attr :current_path, :string, default: "/"
  attr :current_scope, :map, default: %{}

  def navbar(assigns) do
    ~H"""
    <nav class="w-full bg-base-100 shadow-sm mb-4">
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 justify-between">
          <div class="flex">
            <.link navigate={~p"/"} class="flex shrink-0 items-center">
              <img class="h-8 w-auto" src={~p"/images/logo_logogram_only.svg"} alt="CSS Clash Logo" />
            </.link>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <%= if @current_scope do %>
                <.header_link to={~p"/targets"} label="Targets" current_path={@current_path} />
              <% end %>
            </div>
          </div>
          <div class="hidden sm:ml-6 sm:flex sm:items-center">
            <.theme_toggle />
            <div class="relative ml-3" phx-click-away={hide_user_menu()}>
              <div>
                <button
                  type="button"
                  class="cursor-pointer relative flex rounded-full p-2 bg-base-200 text-sm focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:outline-hidden"
                  id="user-menu-button"
                  aria-expanded="false"
                  aria-haspopup="true"
                  phx-click={toggle_user_menu()}
                >
                  <span class="absolute -inset-1.5"></span>
                  <span class="sr-only">{gettext("open_user_menu")}</span>
                  <.icon name="hero-user" class="size-6" />
                </button>
              </div>
              <div
                id="user-dropdown-menu"
                class="hidden absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-base-100 py-1 shadow-lg ring-1 ring-base-300 focus:outline-hidden"
                role="menu"
                aria-orientation="vertical"
                aria-labelledby="user-menu-button"
                tabindex="-1"
              >
                <%= if @current_scope do %>
                  <.user_menu_link
                    to={~p"/users/settings"}
                    label={dgettext("users", "settings")}
                    current_path={@current_path}
                  />
                  <.user_menu_link
                    to={~p"/users/log-out"}
                    label={dgettext("users", "logout")}
                    current_path={@current_path}
                    method="delete"
                  />
                <% else %>
                  <.user_menu_link
                    to={~p"/users/register"}
                    label={dgettext("users", "register")}
                    current_path={@current_path}
                  />
                  <.user_menu_link
                    to={~p"/users/log-in"}
                    label={dgettext("users", "login")}
                    current_path={@current_path}
                  />
                <% end %>
              </div>
            </div>
          </div>
          <div class="-mr-2 flex items-center sm:hidden">
            <button
              id="mobile-menu-button"
              type="button"
              class="relative inline-flex items-center justify-center rounded-md p-2 text-base-content hover:bg-base-200 focus:ring-2 focus:ring-primary focus:outline-hidden focus:ring-inset"
              aria-controls="mobile-menu"
              phx-click={toggle_mobile_menu()}
            >
              <span class="absolute -inset-0.5"></span>
              <span class="sr-only">{gettext("open_main_menu")}</span>
              <.icon name="hero-bars-3" class="block size-6" />
              <.icon name="hero-x-mark" class="hidden size-6" />
            </button>
          </div>
        </div>
      </div>

      <div
        class="hidden border-b shadow-sm mb-4"
        id="mobile-menu"
        phx-click-away={close_mobile_menu()}
      >
        <div class="space-y-1 pt-2 pb-3">
          <%= if @current_scope do %>
            <.mobile_menu_link to={~p"/targets"} label="Targets" current_path={@current_path} />
          <% end %>
        </div>
        <div class="border-t pt-4 pb-3">
          <div :if={@current_scope} class="flex items-center px-4">
            <div class="shrink-0 bg-base-200 rounded-full p-2">
              <.icon name="hero-user" class="size-10" />
            </div>
            <div class="ml-3">
              <div class="text-sm font-medium text-base-content">{@current_scope.user.email}</div>
            </div>
          </div>
          <div class="mt-3 space-y-1">
            <%= if @current_scope do %>
              <.mobile_menu_link
                to={~p"/users/settings"}
                label={dgettext("users", "settings")}
                current_path={@current_path}
              />
              <.mobile_menu_link
                to={~p"/users/log-out"}
                label={dgettext("users", "logout")}
                current_path={@current_path}
                method="delete"
              />
            <% else %>
              <.mobile_menu_link
                to={~p"/users/register"}
                label={dgettext("users", "register")}
                current_path={@current_path}
              />
              <.mobile_menu_link
                to={~p"/users/log-in"}
                label={dgettext("users", "login")}
                current_path={@current_path}
              />
            <% end %>
          </div>
        </div>
      </div>
    </nav>
    """
  end

  attr :to, :string, required: true
  attr :label, :string, required: true
  attr :current_path, :string, default: "/"
  attr :class, :string, default: ""

  defp header_link(assigns) do
    assigns =
      assigns
      |> assign(active?: String.starts_with?(assigns.current_path, assigns.to))

    ~H"""
    <.link
      navigate={@to}
      class={
        classes([
          if(
            @active?,
            do: "border-primary px-1 pt-1 text-sm font-medium text-primary-content",
            else: "border-transparent px-1 pt-1 text-sm font-medium hover:border-secondary"
          ),
          "inline-flex items-center border-b-2 inline-flex items-center border-b-2 text-base-content",
          @class
        ])
      }
    >
      {@label}
    </.link>
    """
  end

  attr :to, :string, required: true
  attr :label, :string, required: true
  attr :current_path, :string, required: true
  attr :method, :string, default: "get"
  attr :class, :string, default: ""

  defp user_menu_link(assigns) do
    assigns =
      assigns
      |> assign(active?: assigns.to == assigns.current_path)

    ~H"""
    <.link
      href={@to}
      class={
        classes([
          if(
            @active?,
            do: "bg-base-200 outline-hidden",
            else: "bg-base-100"
          ),
          "block px-4 py-2 text-sm text-base-content hover:bg-base-200",
          @class
        ])
      }
      role="menuitem"
      method={@method}
    >
      {@label}
    </.link>
    """
  end

  attr :to, :string, required: true
  attr :label, :string, required: true
  attr :current_path, :string, required: true
  attr :method, :string, default: "get"
  attr :class, :string, default: ""

  def mobile_menu_link(assigns) do
    assigns =
      assigns
      |> assign(active?: assigns.to == assigns.current_path)

    ~H"""
    <.link
      href={@to}
      method={@method}
      class={
        classes([
          "block bg-base-100 border-l-4 border-transparent py-2 pr-4 pl-3 font-medium text-base-content hover:border-secondary hover:bg-base-200 hover:text-base-content",
          @active? && "border-primary bg-neutral text-neutral-content",
          @class
        ])
      }
    >
      {@label}
    </.link>
    """
  end

  defp toggle_user_menu(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#user-dropdown-menu",
      in: {
        "transition ease-out duration-200",
        "transform opacity-0 scale-95",
        "transform opacity-100 scale-100"
      },
      out: {
        "transition ease-in duration-75",
        "transform opacity-100 scale-100",
        "transform opacity-0 scale-95"
      }
    )
  end

  defp hide_user_menu(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#user-dropdown-menu",
      transition: {
        "transition ease-in duration-75",
        "transform opacity-100 scale-100",
        "transform opacity-0 scale-95"
      }
    )
  end

  defp toggle_mobile_menu(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#mobile-menu",
      in: {
        "transition ease-out duration-300",
        "transform opacity-0",
        "transform opacity-100"
      },
      out: {
        "transition ease-in duration-200",
        "transform opacity-100",
        "transform opacity-0"
      }
    )
  end

  defp close_mobile_menu(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#mobile-menu",
      transition: {
        "transition ease-in duration-200",
        "transform opacity-100",
        "transform opacity-0"
      }
    )
  end
end
