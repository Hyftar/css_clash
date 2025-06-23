defmodule CssClashWeb.HtmlRenderHTML do
  use CssClashWeb, :html

  def render_html(assigns) do
    ~H"""
    <style>
      body {
        background-color: #000;
        margin: 0;
      }
    </style>
    <iframe
      srcdoc="<html><head></head><body style='overflow: hidden;'></body></html>"
      width="500"
      height="500"
      sandbox="allow-same-origin"
    >
    </iframe>
    """
  end
end
