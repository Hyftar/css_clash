defmodule CssClash.SubmissionEvaluator do
  alias CssClash.HtmlVisualiser

  def evaluate_submission_async(
        %{image_data: target_image} = _target,
        %{html: html, css: css} = _submission
      ) do
    Task.async(fn ->
      {:ok, rendered_image, image_file_path} =
        HtmlVisualiser.convert_html_to_image(html, css, cleanup_file: false)

      target_image = Image.open!(target_image)

      score = evaluate_submission_score(target_image, rendered_image)

      File.rm!(image_file_path)

      {:ok, score}
    end)
  end

  @error_tolerance 0.002

  def evaluate_submission_score(target_image, submission_image) do
    Image.compare(target_image, submission_image)
    |> then(fn {:ok, comparison_metric, _} ->
      if(
        comparison_metric <= @error_tolerance,
        do: 1.0,
        else: 1.0 - comparison_metric
      )
    end)
  end
end
