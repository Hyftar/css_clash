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

    image_file_name =
      :crypto.hash(:md5, query)
      |> Base.encode16(case: :lower)

    image_file_path = Path.join("screenshots", "#{image_file_name}.png")

    Wallaby.start_session(
      window_size: [width: 500, height: 639],
      headless: true
    )
    |> then(fn {:ok, session} -> session end)
    |> visit("/render/html_render")
    |> execute_script(
      """
      const frameDoc = document.querySelector('iframe').contentDocument;

      const styleElem = frameDoc.createElement('style');
      styleElem.innerHTML = arguments[1];
      frameDoc.head.appendChild(styleElem);

      frameDoc.body.innerHTML = arguments[0];
      """,
      [html, css]
    )
    |> take_screenshot(name: image_file_name)
    |> Wallaby.end_session()

    {:ok, image} = Image.open(image_file_path)
    {:ok, image, image_file_path}
  end
end
