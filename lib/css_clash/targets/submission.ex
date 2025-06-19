defmodule CssClash.Targets.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :score, :float
    field :html, :string, default: ""
    field :css, :string, default: ""

    belongs_to :user, CssClash.Accounts.User
    belongs_to :target, CssClash.Targets.Target

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(user_id target_id)a
  @optional_fields ~w(html css score)a
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
