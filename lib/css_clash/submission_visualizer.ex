defmodule CssClash.SubmissionVisualizer do
  @moduledoc """
  Module for generating visual representations of submissions.
  Uses Gotenberg to render HTML/CSS submissions as images.
  """
  def convert_submission_to_image(id) do
    submission_url =
      "#{Application.get_env(:css_clash, :internal_app_url)}/render/submission/#{id}"

    gotenberg_url =
      "#{Application.get_env(:css_clash, :gotenberg_url)}/forms/chromium/screenshot/url"

    body = [
      {"url", submission_url},
      {"width", "500"},
      {"height", "500"},
      {"format", "png"},
      {"clip", "true"},
      {"skipNetworkIdleEvent", "false"}
    ]

    case HTTPoison.post(
           gotenberg_url,
           {:multipart, body},
           [{"Content-Type", "multipart/form-data"}],
           []
         ) do
      {:ok, %{status_code: 200, body: image_data}} ->
        Image.open(image_data)

      {:ok, %{status_code: status_code, body: error_body}} ->
        {:error, "Failed to generate image, status: #{status_code} -- #{error_body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end
end
