defmodule CssClash.HtmlVisualiser do
  import Wallaby.Browser

  def convert_html_to_image(html, css) do
    {:ok, _} = Application.ensure_all_started(:wallaby)

    query =
      %{
        html: html,
        css: css
      }
      |> URI.encode_query()

    query_hash =
      :crypto.hash(:md5, query)
      |> Base.encode16(case: :lower)

    Wallaby.start_session(
      window_size: [width: 500, height: 639],
      headless: true
    )
    |> then(fn {:ok, session} -> session end)
    |> visit("/html_render?#{query}")
    |> take_screenshot(name: query_hash)
    |> Wallaby.end_session()

    {:ok, query_hash <> ".png"}
  end
end
