defmodule CssClashWeb.Components.Target.Display do
  use CssClashWeb, :live_component

  alias CssClash.Targets
  alias CssClash.Targets.Submission
  alias CssClash.SubmissionEvaluator

  alias Phoenix.LiveView.AsyncResult

  import CssClashWeb.Components.Target.DocumentRender

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
      |> assign(show_success_message: false)
      |> assign(
        score: if(user_submission.score, do: AsyncResult.ok(user_submission.score), else: nil)
      )
      |> assign(current_user: assigns.current_user)
      |> assign(target: assigns.target)
      |> assign(user_submission: user_submission)
      |> assign(initial_html: user_submission.html)
      |> assign(initial_css: user_submission.css)
      |> maybe_congratulate_user()

    {:ok, socket}
  end

  def handle_event("save_progress", _, %{assigns: %{user_submission: %{score: 1.0}}} = socket) do
    {:noreply, socket}
  end

  def handle_event("save_progress", %{"html" => html, "css" => css}, socket) do
    socket =
      Targets.update_submission(socket.assigns.user_submission, %{html: html, css: css})
      |> then(fn {:ok, submission} -> submission end)
      |> then(fn submission -> assign(socket, user_submission: submission) end)

    {:noreply, socket}
  end

  def handle_event("submit", %{"html" => html, "css" => css}, socket) do
    target = socket.assigns.target

    submission =
      if socket.assigns.user_submission.score < 1.0 do
        Targets.submit_submission(socket.assigns.user_submission, %{html: html, css: css})
      else
        Targets.create_submission(%{
          html: html,
          css: css,
          user_id: socket.assigns.current_user.id,
          target_id: target.id
        })
      end
      |> then(fn {:ok, submission} -> submission end)

    socket =
      socket
      |> assign(score: AsyncResult.loading())
      |> start_async(
        :evaluate_submission_score,
        fn ->
          SubmissionEvaluator.evaluate_submission(
            target,
            submission
          )
        end
      )

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

  def handle_event("reset", _params, socket) do
    new_submission =
      Targets.create_submission(%{
        user_id: socket.assigns.current_user.id,
        target_id: socket.assigns.target.id
      })
      |> then(fn {:ok, submission} -> submission end)

    socket =
      socket
      |> assign(score: nil)
      |> assign(user_submission: new_submission)
      |> assign(show_success_message: false)
      |> assign(initial_html: "")
      |> assign(initial_css: "")
      |> push_event("css_clash:reset_editor", %{"fullReset" => true})

    {:noreply, socket}
  end

  def handle_async(
        :evaluate_submission_score,
        {:ok, %Submission{score: new_score} = submission},
        %{assigns: %{score: score}} = socket
      ) do
    socket =
      socket
      |> assign(score: AsyncResult.ok(score, new_score))
      |> assign(user_submission: submission)
      |> maybe_congratulate_user()

    {:noreply, socket}
  end

  def handle_async(
        :evaluate_submission_score,
        {:exit, reason},
        %{assigns: %{score: score}} = socket
      ) do
    {:noreply, assign(socket, :score, AsyncResult.failed(score, {:exit, reason}))}
  end

  def maybe_congratulate_user(
        %{
          assigns: %{
            score: %{result: 1.0},
            user_submission: %Submission{congratulated: false} = submission
          }
        } = socket
      ) do
    {:ok, submission} = Targets.update_submission(submission, %{congratulated: true})

    socket
    |> push_event("css_clash:confetti", %{})
    |> assign(show_success_message: true)
    |> assign(submission: submission)
  end

  def maybe_congratulate_user(socket), do: socket

  attr :id, :string, required: false

  def render(assigns) do
    assigns = assign(assigns, readonly: assigns.user_submission.score == 1.0)

    ~H"""
    <div
      id={"target-display-#{@current_user.id}"}
      phx-hook="TargetDisplayHook"
      class="grid grid-cols-[1fr_minmax(500px,_1fr)] gap-x-8 justify-start overflow-y-auto"
    >
      <section class="flex flex-col gap-y-8 justify-start">
        <div :if={@score && @score.ok?}>
          {dgettext("game_display", "score", score: Submission.score_to_human(@score))}
        </div>
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
            data-readonly={@readonly && "true"}
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
            data-readonly={@readonly && "true"}
            class="min-h-32 grow-0 overflow-y-auto"
          >
          </div>
        </div>
      </section>
      <section class="flex flex-col items-center grow-1 gap-4">
        <.document_render
          unique_id={@current_user.id}
          target={@target}
          diff_mode={@diff_mode}
          score={@score}
          myself={@myself}
        />
      </section>
    </div>
    """
  end
end
