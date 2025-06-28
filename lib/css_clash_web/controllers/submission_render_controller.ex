defmodule CssClashWeb.SubmissionRenderController do
  use CssClashWeb, :controller
  import Phoenix.Component, only: [sigil_H: 2]

  alias CssClash.Repo
  alias CssClash.Targets.Submission

  @doc """
  Renders a submission by its ID.
  The submission's HTML and CSS are combined into a single document.
  """
  def render_submission(conn, %{"id" => id}) do
    case Repo.get(Submission, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_resp_content_type("text/html")
        |> send_resp(404, "Not Found")

      submission ->
        content = render_submission_template(%{submission: submission})

        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, content)
    end
  end

  defp render_submission_template(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>CSS Clash Submission</title>
        <style>
          body {
            margin: 0;
            background: white;
            width: 500px;
            height: 500px;
            overflow: hidden;
          }

          iframe {
            border: none;
          }
        </style>
      </head>
      <body>
        <iframe srcdoc={submission_document(assigns)} width="500" height="500" sandbox=""></iframe>
      </body>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
  end

  defp submission_document(assigns) do
    ~H"""
    <html>
      <head>
        <meta
          http-equiv="Content-Security-Policy"
          content="img-src 'none'; style-src 'unsafe-inline';"
        />
        <style>
          <%= @submission.css %>
        </style>
      </head>
      <body>{@submission.html |> Phoenix.HTML.raw()}</body>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
  end
end
