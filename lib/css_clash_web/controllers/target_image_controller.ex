defmodule CssClashWeb.TargetImageController do
  use CssClashWeb, :controller

  alias CssClash.Targets

  @doc """
  Serves the image from the Targets table as if it were a static asset.
  Route pattern: /target-images/:id
  """
  def show(conn, %{"id" => slug}) do
    # Extract the format from the content type negotiation
    format = extract_format_from_path(slug)
    slug = slug |> String.replace(~r/\.\w+$/, "")

    # Try to fetch the target, handle case when not found
    case fetch_target_and_serve_image(conn, slug, format) do
      {:ok, conn} ->
        conn

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(html: CssClashWeb.ErrorHTML)
        |> render("404.html")
    end
  end

  # Extract format from path if it exists (e.g., "slug.png" -> "png")
  defp extract_format_from_path(path) do
    case Regex.run(~r/\.([^.]+)$/, path) do
      [_, format] -> format
      # Default to png if no extension
      _ -> "png"
    end
  end

  defp fetch_target_and_serve_image(conn, slug, format) do
    # Try to get the target by slug
    try do
      target = Targets.get_target_by_slug!(slug)

      # Ensure the target has image data
      if target.image_data && byte_size(target.image_data) > 0 do
        conn =
          conn
          |> put_resp_content_type(content_type_for_format(format))
          # Cache for 2 hours
          |> put_resp_header("cache-control", "public, max-age=7200")
          |> send_resp(200, target.image_data)

        {:ok, conn}
      else
        {:error, :not_found}
      end
    rescue
      Ecto.NoResultsError -> {:error, :not_found}
    end
  end

  # Helper to determine content type based on file extension
  defp content_type_for_format(format) do
    case String.downcase(format) do
      "png" -> "image/png"
      "jpg" -> "image/jpeg"
      "jpeg" -> "image/jpeg"
      "gif" -> "image/gif"
      "svg" -> "image/svg+xml"
      "webp" -> "image/webp"
      # Default fallback
      _ -> "application/octet-stream"
    end
  end
end
