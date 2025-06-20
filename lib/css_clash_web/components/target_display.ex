defmodule CssClashWeb.Components.TargetDisplay do
  use CssClashWeb, :live_component

  alias CssClash.Targets
  alias CssClash.SubmissionEvaluator

  import CssClashWeb.Components.TargetRender

  def update(assigns, socket) do
    user_submission =
      Targets.create_or_get_latest_submission(
        assigns.current_user.id,
        assigns.target.id
      )
      |> then(fn {:ok, submission} -> submission end)

    socket =
      socket
      |> assign(diff_mode: false)
      |> assign(current_user: assigns.current_user)
      |> assign(target: assigns.target)
      |> assign(user_submission: user_submission)
      |> assign(initial_html: user_submission.html)
      |> assign(initial_css: user_submission.css)
      |> assign(score: assigns.score)

    {:ok, socket}
  end

  def handle_event("submit", %{"html" => html, "css" => css}, socket) do
    SubmissionEvaluator.evaluate_submission_async(
      socket.assigns.target,
      %{html: html, css: css}
    )

    {:noreply, socket}
  end

  def handle_event("save_progress", %{"html" => html, "css" => css}, socket) do
    socket =
      Targets.update_submission(socket.assigns.user_submission, %{html: html, css: css})
      |> then(fn {:ok, submission} -> submission end)
      |> then(fn submission -> assign(socket, user_submission: submission) end)

    {:noreply, socket}
  end

  def handle_event("toggle_diff_mode", %{"value" => "on"}, socket) do
    socket =
      socket
      |> assign(diff_mode: true)

    {:noreply, socket}
  end

  def handle_event("toggle_diff_mode", _params, socket) do
    socket =
      socket
      |> assign(diff_mode: false)

    {:noreply, socket}
  end

  attr :id, :string, required: false

  def render(assigns) do
    ~H"""
    <div
      id={"target-display-#{@current_user.id}"}
      phx-hook="TargetDisplayHook"
      class="grid grid-cols-[1fr_minmax(500px,_1fr)] gap-x-8 justify-start overflow-y-auto"
    >
      <section class="flex flex-col gap-y-8 justify-start">
        <div>{@score || "not yet submitted"}</div>
        <div class="overflow-y-auto max-h-96">
          <header class="sticky top-0 z-10 bg-base-100 text-base-800 pb-4 text-lg">
            {dgettext("game_display", "html_editor")}
          </header>
          <div
            id={"html-editor-#{@current_user.id}"}
            phx-hook="CodeMirrorHook"
            phx-update="ignore"
            data-lang="html"
            data-editor-for={"target-display-#{@current_user.id}"}
            data-initial-content={@initial_html}
            class="min-h-32 grow-0 overflow-y-auto"
          >
          </div>
        </div>
        <div class="overflow-y-auto max-h-96">
          <header class="sticky top-0 z-10 bg-base-100 text-base-800 pb-4 text-lg">
            {dgettext("game_display", "css_editor")}
          </header>
          <div
            id={"css-editor-#{@current_user.id}"}
            phx-hook="CodeMirrorHook"
            phx-update="ignore"
            data-lang="css"
            data-editor-for={"target-display-#{@current_user.id}"}
            data-initial-content={@initial_css}
            class="min-h-32 grow-0 overflow-y-auto"
          >
          </div>
        </div>
      </section>
      <section class="flex flex-col items-center grow-1 gap-4">
        <.target_render
          unique_id={@current_user.id}
          target={@target}
          diff_mode={@diff_mode}
          myself={@myself}
        />
      </section>
    </div>
    """
  end
end
