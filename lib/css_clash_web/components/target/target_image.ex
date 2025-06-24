defmodule CssClashWeb.Components.Target.TargetImage do
  use CssClashWeb, :html

  @doc """
  Generates an image tag for a target image.
  """

  attr :target, :map, required: true, doc: "The target struct or target slug"
  attr :alt, :string, required: true, doc: "The alt text for the image"
  attr :width, :integer, default: 500, doc: "The width of the image"
  attr :height, :integer, default: 500, doc: "The height of the image"
  attr :class, :string, default: "", doc: "CSS classes to apply to the image"
  attr :format, :string, default: "png", doc: "The image format"

  def target_image(assigns) do
    assigns =
      assigns
      |> assign(path: target_image_path(assigns.target, format: assigns.format))

    ~H"""
    <img src={@path} alt={@alt} width={@width} height={@height} class={@class} />
    """
  end
end
