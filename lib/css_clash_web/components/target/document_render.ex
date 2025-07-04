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
    <.tabs id={"document-render-tabs-#{@unique_id}"} class="tabs-box">
      <:tab label={dgettext("game_display", "render_preview")}>
        <div class="flex justify-center gap-8 min-h-8 mt-4">
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
        <div class="flex justify-center mt-4 mb-8 mx-8">
          <div class="relative">
            <.hover_diff unique_id={@unique_id} target={@target} active={@hover_mode} />
            <.target_image
              :if={@diff_mode}
              target={@target}
              class="w-[500px] h-[500px] absolute top-0 left-0 mix-blend-difference pointer-events-none select-none"
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
      </:tab>

      <:tab label={dgettext("game_display", "target_preview")} is_active={true}>
        <div class="flex justify-center mt-16 mb-8 mx-8">
          <.target_image
            target={@target}
            class="min-w-[500px] min-h-[500px]"
            alt="target image reference"
          />
        </div>
      </:tab>
    </.tabs>

    <div class="flex flex-col gap-4 grow-1 w-full mt-4">
      <div class="flex justify-center flex-wrap gap-2">
        <div
          :for={{color, index} <- @target.colors |> Stream.with_index()}
          id={"color-#{index}"}
          class="py-4 badge bg-base-200 badge-soft cursor-pointer hover:bg-base-100"
          phx-click="copied"
          phx-value-color={color}
          phx-hook="CopyTextHook"
          data-copy-text={color}
        >
          <span
            class="size-4 rounded-full outline outline-2 outline-base-content"
            style={"background-color: #{color}"}
          >
          </span>
          <span class="mb-0.5 min-w-12">{color}</span>
          <.icon name="hero-clipboard-document-list-solid" />
        </div>
      </div>
    </div>
    """
  end
end
