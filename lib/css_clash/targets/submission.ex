defmodule CssClash.Targets.Submission do
  alias Phoenix.LiveView.AsyncResult

  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :score, :float
    field :html, :string, default: ""
    field :css, :string, default: ""
    field :congratulated, :boolean, default: false

    belongs_to :user, CssClash.Accounts.User
    belongs_to :target, CssClash.Targets.Target

    timestamps(type: :utc_datetime)
  end

  def submit_changeset(submission, attrs) do
    submission
    |> cast(attrs, [:html, :css])
    |> validate_required([])
  end

  @required_fields ~w(user_id target_id)a
  @optional_fields ~w(html css score congratulated)a
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def score_to_human(nil), do: nil

  def score_to_human(%AsyncResult{result: score}), do: score_to_human(score)

  def score_to_human(score) do
    score
    |> Kernel.*(100)
    |> Kernel.round()
    |> Kernel.to_string()
  end
end
