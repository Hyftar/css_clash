defmodule CssClashWeb.HtmlRenderController do
  use CssClashWeb, :controller

  use Phoenix.Controller, formats: [html: "html_render_html"]

  def render_html(conn, %{"html" => html, "css" => css}) do
    conn
    |> assign(:html, html)
    |> assign(:css, css)
    |> render(:render_html)
  end
end
