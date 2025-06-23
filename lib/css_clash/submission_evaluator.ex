defmodule CssClash.SubmissionEvaluator do
  alias CssClash.HtmlVisualiser
  alias CssClash.Targets

  def evaluate_submission(
        %{image_data: target_image} = _target,
        %{html: html, css: css} = submission
      ) do
    {:ok, rendered_image, image_file_path} =
      HtmlVisualiser.convert_html_to_image(html, css)

    target_image = Image.open!(target_image)

    score = evaluate_submission_score(target_image, rendered_image)

    {:ok, submission} = Targets.update_submission(submission, %{score: score})

    File.rm!(image_file_path)

    submission
  end

  @error_tolerance 0.012

  def evaluate_submission_score(target_image, submission_image) do
    Image.compare(target_image, submission_image, metric: :rmse)
    |> then(fn {:ok, comparison_metric, _} ->
      if(
        comparison_metric <= @error_tolerance,
        do: 1.0,
        else: 1.0 - comparison_metric
      )
    end)
  end
end
