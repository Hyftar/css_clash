defmodule CssClash.HtmlVisualiser do
  import Wallaby.Browser

  def convert_html_to_image(html, css, opts \\ []) do
    {:ok, _} = Application.ensure_all_started(:wallaby)

    query =
      %{
        html: html,
        css: css
      }
      |> URI.encode_query()

    image_file_name =
      :crypto.hash(:md5, query)
      |> Base.encode16(case: :lower)
      |> then(&"#{&1}.png")

    image_file_path = Path.join("screenshots", image_file_name)

    Wallaby.start_session(
      window_size: [width: 500, height: 639],
      headless: true
    )
    |> then(fn {:ok, session} -> session end)
    |> visit("/html_render?#{query}")
    |> take_screenshot(name: image_file_name)
    |> Wallaby.end_session()

    {:ok, image} = Image.open(image_file_path)

    maybe_delete_file(image_file_path, Keyword.get(opts, :cleanup_file, true))

    {:ok, image}
  end

  defp maybe_delete_file(image_file_path, true = should_delete), do: File.rm(image_file_path)
  defp maybe_delete_file(image_file_path, false), do: :ok
end
