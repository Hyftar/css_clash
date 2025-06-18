defmodule CssClashWeb.Plugs.AllowlistIps do
  import Plug.Conn
  require Logger

  @moduledoc """
  Plug to allowlist IPs.
  Use package RemoteIp (`plug(RemoteIp)`) for a more reliable remote IP address.

  ## Examples
  plug(CssClashWeb.Plugs.AllowlistIps, allowlist: ["127.0.0.1"])
  plug(CssClashWeb.Plugs.AllowlistIps, allowlist: [{Application, :fetch_env!, [:blueprint, :allowlist_ips]}])
  """

  def init(opts), do: opts

  def call(conn, opts) do
    allowlist = opts |> Keyword.get(:allowlist, []) |> Enum.map(&parse_ip/1)
    client_ip = convert_ip(conn.remote_ip)

    if client_ip in allowlist do
      conn
    else
      conn
      |> send_resp(401, "Unauthorized")
      |> halt()
    end
  end

  defp convert_ip(ip) when is_tuple(ip) do
    ip
    |> Tuple.to_list()
    |> Enum.map_join(".", &to_string(&1))
  end

  defp parse_ip(ip) when is_binary(ip), do: ip

  defp parse_ip({module, function, args}) do
    apply(module, function, args)
  end
end
