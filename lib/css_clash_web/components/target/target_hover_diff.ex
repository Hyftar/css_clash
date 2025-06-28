defmodule CssClashWeb.Components.Target.TargetHoverDiff do
  use CssClashWeb, :html

  attr :target, :map, required: true
  attr :active, :boolean, default: false
  attr :unique_id, :string, required: true

  def hover_diff(assigns) do
    ~H"""
    <div
      id={"hover-diff-#{@unique_id}"}
      phx-hook="TargetHoverDiffHook"
      phx-update="ignore"
      data-image-path={target_image_path(@target)}
      class="absolute w-[500px] h-[500px]"
    >
      <div class="hover-diff-left" />
      <label class="position-label" />
      <div class="hover-diff-right" />
    </div>
    """
  end
end
