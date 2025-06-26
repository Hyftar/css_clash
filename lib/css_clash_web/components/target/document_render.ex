defmodule CssClashWeb.Components.Target.DocumentRender do
  use CssClashWeb, :html

  import CssClashWeb.Components.Target.TargetImage
  import CssClashWeb.Components.Target.TargetHoverDiff

  attr :unique_id, :string, required: true
  attr :diff_mode, :boolean, required: true
  attr :hover_mode, :boolean, required: true
  attr :myself, :string, required: true
  attr :target, :map, required: true
  attr :score, :map, required: true

  def document_render(assigns) do
    ~H"""
    <div class="flex justify-between items-end gap-4">
      <div>
        <div class="flex justify-between">
          <div>
            <input
              id={"diff-mode-#{@unique_id}"}
              class="toggle toggle-primary"
              type="checkbox"
              checked={@diff_mode}
              phx-click="toggle_diff_mode"
              phx-target={@myself}
              phx-value-checked={if(@diff_mode, do: "true", else: "false")}
            />
            <label for={"diff-mode-#{@unique_id}"}>{dgettext("game_display", "diff_mode")}</label>
          </div>

          <div>
            <input
              id={"hover-mode-#{@unique_id}"}
              type="checkbox"
              class="toggle toggle-primary"
              checked={@hover_mode}
              phx-click="toggle_hover_mode"
              phx-target={@myself}
              phx-value-checked={if(@hover_mode, do: "true", else: "false")}
            />
            <label for={"hover-mode-#{@unique_id}"}>{dgettext("game_display", "hover_mode")}</label>
          </div>
        </div>
        <div class="relative">
          <.hover_diff unique_id={@unique_id} target={@target} active={@hover_mode} />
          <.target_image
            :if={@diff_mode}
            target={@target}
            class="min-w-[500px] min-h-[500px] absolute top-0 left-0 mix-blend-difference pointer-events-none select-none"
            alt="target image for difference mode"
          />

          <iframe
            id={"document-render-#{@target.id}"}
            data-component-name="document-render"
            sandbox=""
            class="min-w-[500px] min-h-[500px] pointer-events-none select-none"
            width="500px"
            height="500px"
            phx-update="ignore"
          >
          </iframe>
        </div>
      </div>
      <div>
        <.target_image
          target={@target}
          class="min-w-[500px] min-h-[500px]"
          alt="target image reference"
        />
      </div>
    </div>
    <div class="flex flex-col gap-4 grow-1 w-full mt-4">
      <div class="flex justify-center flex-wrap gap-2">
        <div
          :for={{color, index} <- @target.colors |> Stream.with_index()}
          id={"color-#{index}"}
          class="text-xs flex items-center gap-2 py-1 px-3
            rounded-full bg-neutral text-slate-200 cursor-pointer
            hover:brightness-125"
          phx-click="copied"
          phx-value-color={color}
          phx-hook="CopyTextHook"
          data-copy-text={color}
        >
          <span
            class="w-[1em] h-[1em] rounded-full outline outline-1 outline-white"
            style={"background-color: #{color}"}
          >
          </span>
          <span class="mb-0.5 min-w-12">{color}</span>
          <.icon name="hero-clipboard-document-list-solid" />
        </div>
      </div>
      <div class="flex gap-2 justify-center">
        <.button
          variant="primary"
          disabled={@score != nil && (@score.loading || @score.result == 1.0)}
          phx-click={JS.dispatch("css_clash:submit", to: "#target-display-#{@unique_id}")}
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
    """
  end
end
