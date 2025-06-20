defmodule CssClashWeb.HtmlRenderController do
  use CssClashWeb, :controller

  def render_html(conn, %{"html" => html, "css" => css}) do
    conn
    |> assign(:html, html)
    |> assign(:css, css)
    |> render(:render_html, layout: false)
  end
end
