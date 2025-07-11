defmodule CssClashWeb.Router do
  use CssClashWeb, :router

  import CssClashWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CssClashWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :renderer do
    plug :accepts, ["html"]

    plug(
      CssClashWeb.Plugs.AllowlistIps,
      allowlist: ["127.0.0.1"],
      log_connections: true
    )
  end

  scope "/", CssClashWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/targets", CssClashWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :targets,
      on_mount: [
        {CssClashWeb.UserAuth, :require_authenticated},
        {CssClashWeb.Hooks.Navigation, :save_request_uri}
      ] do
      live "/", TargetLive.Index, :index
      live "/:id", TargetLive.Show, :show
    end
  end

  # Serve target images without authentication requirement
  scope "/target-images", CssClashWeb do
    pipe_through [:browser]

    # Route for serving images directly from the Targets table
    get "/:id", TargetImageController, :show
  end

  scope "/render", CssClashWeb do
    pipe_through [:renderer]

    get "/submission/:id", SubmissionRenderController, :render_submission
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:css_clash, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CssClashWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CssClashWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {CssClashWeb.UserAuth, :require_authenticated},
        {CssClashWeb.Hooks.Navigation, :save_request_uri}
      ] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", CssClashWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [
        {CssClashWeb.UserAuth, :mount_current_scope},
        {CssClashWeb.Hooks.Navigation, :save_request_uri}
      ] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
