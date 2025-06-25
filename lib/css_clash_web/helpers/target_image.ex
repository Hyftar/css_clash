defmodule CssClashWeb.Helpers.TargetImage do
  @moduledoc """
  Helper functions for generating target image URLs.

  These helpers make it easy to create links to target images served
  from the database via the TargetImageController.
  """

  @doc """
  Generates a path to a target's image.

  ## Parameters

  - `target`: The target struct or target slug
  - `opts`: Options for the URL generation
    - `:format`: The image format (default: "png")

  ## Examples

      # Using a target struct
      iex> target_image_path(%Target{slug: "abc123"})
      "/target-images/abc123.png"

      # Using a target slug
      iex> target_image_path("abc123")
      "/target-images/abc123.png"

      # With a specific format
      iex> target_image_path("abc123", format: "jpg")
      "/target-images/abc123.jpg"
  """
  def target_image_path(target, opts \\ [])

  def target_image_path(%{slug: slug}, opts) do
    target_image_path(slug, opts)
  end

  def target_image_path(slug, opts) when is_binary(slug) do
    format = Keyword.get(opts, :format, "png")
    path = "/target-images/#{slug}"
    if format, do: "#{path}.#{format}", else: path
  end

  @doc """
  Generates a URL to a target's image.

  Similar to `target_image_path/2` but returns a full URL including the host.

  ## Examples

      iex> target_image_url(conn, %Target{slug: "abc123"})
      "http://localhost:4000/target-images/abc123.png"
  """
  def target_image_url(conn_or_endpoint, target, opts \\ [])

  def target_image_url(conn_or_endpoint, %{slug: slug}, opts) do
    target_image_url(conn_or_endpoint, slug, opts)
  end

  def target_image_url(conn_or_endpoint, slug, opts) when is_binary(slug) do
    path = target_image_path(slug, opts)

    endpoint_url =
      if is_struct(conn_or_endpoint) do
        Phoenix.Controller.endpoint_module(conn_or_endpoint).url()
      else
        conn_or_endpoint.url()
      end

    "#{endpoint_url}#{path}"
  end
end
