defmodule CssClash.Repo do
  use Ecto.Repo,
    otp_app: :css_clash,
    adapter: Ecto.Adapters.Postgres
end
