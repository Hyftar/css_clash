defmodule CssClashWeb.HtmlRenderController do
  use CssClashWeb, :controller

  def render_html(conn, %{}) do
    render(conn, :render_html, layout: false)
  end
end
