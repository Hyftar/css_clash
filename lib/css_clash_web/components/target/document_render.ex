defmodule CssClashWeb.Components.Target.DocumentRender do
  use CssClashWeb, :html

  attr :unique_id, :string, required: true
  attr :diff_mode, :boolean, required: true
  attr :myself, :string, required: true
  attr :target, :map, required: true
  attr :score, :map, required: true

  def document_render(assigns) do
    ~H"""
    <div>
      <input
        id="diff-mode"
        type="checkbox"
        checked={@diff_mode}
        phx-click="toggle_diff_mode"
        phx-target={@myself}
      />
      <label for="diff-mode">Diff Mode</label>
    </div>
    <div id="render-preview" class="relative">
      <img
        :if={@diff_mode}
        class="min-w-[500px] min-h-[500px] absolute top-0 left-0 mix-blend-difference"
        src={"data:image/jpeg;base64,#{Base.encode64(@target.image_data)}"}
        width="500px"
        height="500px"
      />
      <iframe
        id={"document-render-#{@target.id}"}
        data-component-name="document-render"
        sandbox=""
        class="min-w-[500px] min-h-[500px]"
        width="500px"
        height="500px"
        phx-update="ignore"
      >
      </iframe>
    </div>
    <div class="flex flex-col gap-4 grow-1 w-full">
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
