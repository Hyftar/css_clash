defmodule CssClash.Targets.Target do
  use Ecto.Schema
  import Ecto.Changeset

  schema "targets" do
    field :name, :string
    field :image_data, :binary
    field :colors, {:array, :string}, default: []

    has_many :submissions, CssClash.Targets.Submission

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(name image_data)a
  @optional_fields ~w(colors)a
  def changeset(target, attrs) do
    target
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
