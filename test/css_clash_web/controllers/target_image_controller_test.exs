defmodule CssClashWeb.TargetImageControllerTest do
  use CssClashWeb.ConnCase

  alias CssClash.Targets
  alias CssClash.Repo
  alias CssClash.Targets.Target

  # Sample test image data - a minimal valid PNG (1x1 transparent pixel)
  @sample_png_data <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0,
                     0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 13, 73, 68, 65, 84, 120,
                     156, 99, 250, 207, 0, 0, 3, 1, 1, 0, 24, 221, 140, 108, 0, 0, 0, 0, 73, 69,
                     78, 68, 174, 66, 96, 130>>

  setup do
    # Create a target with sample image data and a fixed test slug
    {:ok, target} =
      %Target{
        name: "Test Target",
        image_data: @sample_png_data,
        colors: ["#ff0000", "#00ff00"],
        slug: "test-target-slug"
      }
      |> Repo.insert()

    %{target: target}
  end

  describe "show/2" do
    test "serves the image with correct content type when target exists", %{
      conn: conn,
      target: target
    } do
      conn = get(conn, ~p"/target-images/test-target-slug.png")

      assert conn.status == 200

      assert get_content_type(conn) =~ "image/png"

      assert conn.resp_body == @sample_png_data

      assert get_resp_header(conn, "cache-control") == ["public, max-age=7200"]
    end

    test "returns 404 when target does not exist", %{conn: conn} do
      conn = get(conn, ~p"/target-images/nonexistent-slug.png")
      assert conn.status == 404
    end

    test "supports different image formats based on extension", %{conn: conn, target: target} do
      # Test with jpg extension
      conn = get(conn, ~p"/target-images/test-target-slug.jpg")
      assert conn.status == 200
      assert get_content_type(conn) =~ "image/jpeg"

      # Test with svg extension
      conn = get(conn, ~p"/target-images/test-target-slug.svg")
      assert conn.status == 200
      assert get_content_type(conn) =~ "image/svg+xml"
    end
  end

  defp get_content_type(conn) do
    [content_type] = get_resp_header(conn, "content-type")
    content_type
  end
end
