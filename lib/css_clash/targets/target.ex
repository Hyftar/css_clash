defmodule CssClash.Targets.Target do
  use Ecto.Schema
  import Ecto.Changeset

  schema "targets" do
    field :name, :string
    field :image_data, :binary
    field :colors, {:array, :string}, default: []
    field :slug, :string

    has_many :submissions, CssClash.Targets.Submission

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(name image_data)a
  @optional_fields ~w(colors slug)a
  def changeset(target, attrs) do
    target
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil -> put_change(changeset, :slug, UUID.uuid4())
      _ -> changeset
    end
  end
end
