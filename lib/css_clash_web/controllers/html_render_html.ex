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
      srcdoc={"<html><head><style>#{@css}</style></head><body>#{@html}</body></html>"}
      width="500"
      height="500"
      sandbox=""
    >
    </iframe>
    """
  end
end
