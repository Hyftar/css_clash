defmodule CssClash.SubmissionEvaluator do
  alias CssClash.SubmissionVisualizer
  alias CssClash.Targets

  def evaluate_submission(
        %{image_data: target_image} = _target,
        %{id: submission_id} = submission
      ) do
    {:ok, rendered_image} =
      SubmissionVisualizer.convert_submission_to_image(submission_id)

    target_image = Image.open!(target_image)

    score = evaluate_submission_score(target_image, rendered_image)

    {:ok, submission} = Targets.update_submission(submission, %{score: score})

    submission
  end

  @error_tolerance 0.012

  def evaluate_submission_score(target_image, submission_image) do
    submission_image
    |> Image.compare(target_image, metric: :rmse)
    |> then(fn {:ok, comparison_metric, _comp_image} ->
      if(
        comparison_metric <= @error_tolerance,
        do: 1.0,
        else: 1.0 - comparison_metric
      )
    end)
  end
end
