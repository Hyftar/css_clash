defmodule CssClash.Targets.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :score, :float
    field :html, :string
    field :css, :string

    belongs_to :user, CssClash.Targets.User
    belongs_to :target, CssClash.Targets.Target
  end

  @required_fields [:html, :css, :user_id, :target_id]
  @optional_fields [:score]

  def changeset(submission, attrs) do
    submission
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
