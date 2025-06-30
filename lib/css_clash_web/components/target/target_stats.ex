defmodule CssClashWeb.Components.Target.TargetStats do
  use CssClashWeb, :html

  import Tails

  attr :score, :map, required: true
  attr :highscore, :float, required: true
  attr :submission_count, :integer, required: true
  attr :user_submission_count, :integer, required: true
  attr :players_count, :integer, required: true
  attr :success_rate, :float, required: true

  def stats_display(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-2">
      <.stats_card class="hidden md:block" title_class="text-sm">
        <:icon><.icon name="hero-globe-alt" class="size-8" /></:icon>
        <:title>{dgettext("game_display", "submission_count")}</:title>
        {@submission_count}
      </.stats_card>

      <.stats_card class="hidden md:block" title_class="text-sm">
        <:icon><.icon name="hero-paper-airplane" class="size-8" /></:icon>
        <:title>{dgettext("game_display", "user_submission_count")}</:title>
        {@user_submission_count}
      </.stats_card>

      <.stats_card class="hidden md:block" title_class="text-sm">
        <:icon><.icon name="hero-presentation-chart-line" class="size-8" /></:icon>
        <:title>{dgettext("game_display", "success_rate")}</:title>
        {(@success_rate * 100) |> Float.round(2) |> :erlang.float_to_binary(decimals: 2)} %
      </.stats_card>

      <.stats_card class="hidden md:block" title_class="text-sm">
        <:icon><.icon name="hero-users" class="size-8" /></:icon>
        <:title>{dgettext("game_display", "players_count")}</:title>
        {@players_count}
      </.stats_card>

      <.score_display title={dgettext("game_display", "highscore")} score={@highscore} />
      <.score_display title={dgettext("game_display", "current_score")} score={@score} />
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :title_class, :string, default: ""

  slot :inner_block, required: true
  slot :title, required: true
  slot :icon, required: false

  defp stats_card(assigns) do
    ~H"""
    <div class={
      classes([
        "card card-border bg-base-200 border-base-300 flex flex-row justify-between items-center p-2",
        @class
      ])
    }>
      <div class="flex flex-row justify-start items-center gap-4">
        <div :if={@icon}>
          {render_slot(@icon)}
        </div>
        <div>
          <div class={classes(["text-lg font-bold me-4", @title_class])}>
            {render_slot(@title)}
          </div>
          <div>
            {render_slot(@inner_block)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :score, :map, required: true
  attr :title, :string, required: true

  defp score_display(assigns) do
    percentage_score =
      get_value(assigns.score)
      |> then(fn score ->
        if score do
          trunc(score * 100)
        else
          0
        end
      end)

    assigns =
      assign(
        assigns,
        percentage_score: percentage_score
      )

    ~H"""
    <div class={
      classes([
        "card card-border bg-base-200 border-base-300 flex flex-row justify-between items-center p-2",
        "col-span-1 xl:col-span-2"
      ])
    }>
      <div class="text-lg font-bold me-4">
        {@title}
      </div>
      <div
        class={[score_indicator_classes(@score), "radial-progress"]}
        style={"--value:#{@percentage_score}; --size:4rem;"}
        aria-valuenow={@percentage_score}
        role="progressbar"
      >
        <%= case @score do %>
          <% %{ ok?: true} -> %>
            {@percentage_score}%
          <% %{ ok?: false } -> %>
            <span class="loading loading-spinner text-primary-content"></span>
          <% nil -> %>
            <span>--</span>
          <% _ -> %>
            {@percentage_score}%
        <% end %>
      </div>
    </div>
    """
  end

  defp get_value(%{ok?: true, result: result}), do: result
  defp get_value(%{ok?: false, result: result}), do: result
  defp get_value(result), do: result

  defp score_indicator_classes(score) do
    case score do
      nil -> "text-primary-content"
      %{ok?: true, result: 1.0} -> "bg-success text-primary-content"
      1.0 -> "bg-success text-primary-content"
      _ -> "text-primary-content"
    end
  end
end
