defmodule CssClash.SubmissionEvaluator do
  @error_tolerance 0.002

  def evaluate_submission_score(target_image, submission_image) do
    Image.compare(target_image, submission_image)
    |> then(fn {:ok, comparison_metric, _} ->
      if(
        comparison_metric <= @error_tolerance,
        do: 1.0,
        else: comparison_metric
      )
    end)
  end
end
