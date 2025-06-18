defmodule CssClashWeb.Components.GameDisplay do
  use CssClashWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(id: UUID.uuid4())
      |> assign(colors: Stream.repeatedly(&random_color/0) |> Enum.take(4))

    {:ok, socket}
  end

  def handle_event("submit", %{"html" => html, "css" => css}, socket) do
    {:noreply, socket}
  end

  attr :id, :string, required: false

  def render(assigns) do
    ~H"""
    <div
      id={"game-display-#{@id}"}
      phx-hook="GameDisplayHook"
      class="grid grid-cols-[2fr_minmax(550px,_1fr)] gap-x-8 justify-start overflow-y-auto"
    >
      <section class="flex flex-col gap-y-8 justify-start">
        <div class="overflow-y-auto max-h-96">
          <header class="sticky top-0 z-10 bg-base-100 text-base-800 pb-4 text-lg">
            {dgettext("game_display", "html_editor")}
          </header>
          <div
            id={"html-editor-#{@id}"}
            phx-hook="CodeMirrorHook"
            data-lang="html"
            data-editor-for={"game-display-#{@id}"}
            class="min-h-32 grow-0 overflow-y-auto"
          >
          </div>
        </div>
        <div class="overflow-y-auto max-h-96">
          <header class="sticky top-0 z-10 bg-base-100 text-base-800 pb-4 text-lg">
            {dgettext("game_display", "css_editor")}
          </header>
          <div
            id={"css-editor-#{@id}"}
            phx-hook="CodeMirrorHook"
            data-lang="css"
            data-editor-for={"game-display-#{@id}"}
            class="min-h-32 grow-0 overflow-y-auto"
          >
          </div>
        </div>
      </section>
      <section class="flex flex-col items-center grow-1 gap-4">
        <iframe
          id="game-render"
          data-render-for={"game-display-#{@id}"}
          sandbox=""
          class="min-w-[500px] min-h-[500px]"
          width="500px"
          height="500px"
        >
        </iframe>
        <div class="flex flex-col gap-4 grow-1 w-full">
          <div class="flex justify-center flex-wrap gap-2">
            <div
              :for={{color, index} <- @colors |> Stream.with_index()}
              id={"color-#{index}"}
              class="text-xs flex items-center gap-2 py-1 px-3
                rounded-full bg-neutral text-slate-200 cursor-pointer
                hover:brightness-125"
              phx-hook="CopyTextHook"
              phx-click="copied"
              phx-value-color={color}
              data-copy-text={color}
            >
              <span
                class="w-[1em] h-[1em] rounded-full outline outline-1 outline-white"
                style={"background-color: #{color}"}
              >
              </span>
              <span class="mb-0.5 min-w-18">{color}</span>
              <.icon name="hero-clipboard-document-list-solid" />
            </div>
          </div>
          <div class="flex justify-center">
            <.button
              variant="primary"
              phx-click={JS.dispatch("css_clash:submit", to: "#game-display-#{@id}")}
            >
              <span class="me-2">{dgettext("game_display", "submit")}</span>
              <.icon name="hero-paper-airplane-solid" class="-rotate-45 -translate-y-0.5" />
            </.button>
          </div>
        </div>
      </section>
    </div>
    """
  end

  defp random_color do
    Stream.repeatedly(fn -> Enum.random(0..255) end)
    |> Enum.take(3)
    |> Enum.join(",")
    |> then(&"rgb(#{&1})")
  end
end
