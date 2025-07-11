defmodule CssClashWeb.Components.Target.Display do
  use CssClashWeb, :live_component

  alias CssClash.Targets
  alias CssClash.Targets.Submission
  alias CssClash.SubmissionEvaluator

  alias Phoenix.LiveView.AsyncResult

  import CssClashWeb.Components.Target.DocumentRender
  import CssClashWeb.Components.Target.TargetStats

  def update(assigns, socket) do
    user_submission =
      Targets.create_or_get_latest_submission(
        assigns.current_user.id,
        assigns.target.id
      )
      |> then(fn {:ok, submission} -> submission end)

    socket =
      socket
      |> assign(target: assigns.target)
      |> assign(current_user: assigns.current_user)
      |> assign(diff_mode: false)
      |> assign(hover_mode: true)
      |> assign(show_success_message: false)
      |> assign(score: AsyncResult.ok(user_submission.score))
      |> assign(user_submission: user_submission)
      |> assign(initial_html: user_submission.html)
      |> assign(initial_css: user_submission.css)
      |> update_stats()
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
      |> push_event("css_clash:set_readonly", %{readonly: true})
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

  def handle_event("toggle_diff_mode", %{"checked" => value}, socket) do
    socket =
      socket
      |> assign(diff_mode: not String.to_existing_atom(value))

    {:noreply, socket}
  end

  def handle_event("toggle_hover_mode", %{"checked" => value}, socket) do
    is_active = not String.to_existing_atom(value)

    socket =
      socket
      |> assign(hover_mode: is_active)
      |> push_event("css_clash:toggle_hover_mode", %{active: is_active})

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
      |> assign(score: AsyncResult.ok(nil))
      |> assign(user_submission: new_submission)
      |> assign(show_success_message: false)
      |> assign(initial_html: "")
      |> assign(initial_css: "")
      |> push_event("css_clash:reset_editor", %{"fullReset" => true})
      |> push_event("css_clash:set_readonly", %{readonly: false})

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
      |> push_event("css_clash:set_readonly", %{readonly: new_score == 1.0})
      |> assign(user_submission: submission)
      |> update_stats()
      |> maybe_congratulate_user()

    {:noreply, socket}
  end

  def handle_async(
        :evaluate_submission_score,
        {:exit, reason},
        %{assigns: %{score: score}} = socket
      ) do
    socket =
      socket
      |> update_stats()
      |> assign(:score, AsyncResult.failed(score, {:exit, reason}))

    {:noreply, socket}
  end

  defp update_stats(socket) do
    assigns = socket.assigns

    socket
    |> assign(highscore: Targets.get_user_highscore(assigns.target.id, assigns.current_user.id))
    |> assign(players_count: Targets.count_players(assigns.target.id))
    |> assign(success_rate: Targets.get_success_rate(assigns.target.id))
    |> assign(submission_count: Targets.count_submissions(assigns.target.id))
    |> assign(
      user_submission_count: Targets.count_submissions(assigns.target.id, assigns.current_user.id)
    )
  end

  defp maybe_congratulate_user(
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

  defp maybe_congratulate_user(socket), do: socket

  attr :id, :string, required: false

  def render(assigns) do
    assigns = assign(assigns, readonly: assigns.user_submission.score == 1.0)

    ~H"""
    <div>
      <div
        id={"target-display-#{@current_user.id}"}
        class="flex justify-between gap-4 mx-4"
        phx-hook="TargetDisplayHook"
      >
        <div class="grow flex flex-col h-[90vh] overflow-hidden min-w-[250px]">
          <.editor
            title={dgettext("game_display", "html_editor")}
            type="html"
            initial_content={@initial_html}
            user_id={@current_user.id}
            readonly={@readonly}
          />
          <.editor
            class="mt-4"
            title={dgettext("game_display", "css_editor")}
            type="css"
            initial_content={@initial_css}
            user_id={@current_user.id}
            readonly={@readonly}
          />
          <div class="flex flex-col gap-4 w-full mt-4">
            <.stats_display
              score={@score}
              players_count={@players_count}
              user_submission_count={@user_submission_count}
              submission_count={@submission_count}
              highscore={@highscore}
              success_rate={@success_rate}
            />

            <div class="flex gap-2 justify-center">
              <.button
                variant="primary"
                disabled={@score != nil && (@score.loading || @score.result == 1.0)}
                phx-click={JS.dispatch("css_clash:submit", to: "#target-display-#{@current_user.id}")}
              >
                <%= if @score && @score.loading do %>
                  <span class="me-2">{dgettext("game_display", "working")}</span>
                  <.spinner />
                <% else %>
                  <span class="me-2">{dgettext("game_display", "submit")}</span>
                  <.icon name="hero-paper-airplane-solid" class="-rotate-45 -translate-y-0.5" />
                <% end %>
              </.button>
              <.button
                disabled={!@score || @score.result != 1.0}
                variant="secondary"
                phx-click="reset"
                phx-target={@myself}
              >
                {dgettext("game_display", "reset")}
                <.icon name="hero-sparkles" class="size-6" />
              </.button>
            </div>
          </div>
        </div>
        <div class="shrink-0 min-w-[600px]">
          <.document_render
            unique_id={@current_user.id}
            target={@target}
            diff_mode={@diff_mode}
            hover_mode={@hover_mode}
            score={@score}
            myself={@myself}
          />
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :type, :string, required: true
  attr :initial_content, :string, required: true
  attr :user_id, :integer, required: true
  attr :readonly, :boolean, required: true
  attr :class, :string, required: false, default: ""

  defp editor(assigns) do
    ~H"""
    <div class={["flex flex-col flex-1 min-h-0", @class]}>
      <header class="sticky top-0 z-10 bg-base-100 text-base-800 pb-4 text-lg">
        <%!-- {dgettext("game_display", "css_editor")} --%>
        {@title}
      </header>
      <div
        id={"#{@type}-editor-#{@user_id}"}
        phx-hook="CodeMirrorHook"
        phx-update="ignore"
        data-lang={@type}
        data-editor-for={"target-display-#{@user_id}"}
        data-initial-content={@initial_content}
        data-readonly={@readonly && "true"}
        class="flex-1 overflow-auto min-h-0 max-h-[100%]"
      >
      </div>
    </div>
    """
  end
end
