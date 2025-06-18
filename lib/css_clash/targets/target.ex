defmodule CssClash.Targets.Target do
  use Ecto.Schema
  import Ecto.Changeset

  schema "targets" do
    field :name, :string
    field :image_data, :binary
    field :colors, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(target, attrs) do
    target
    |> cast(attrs, [:name, :image_data, :colors])
    |> validate_required([:name, :image_data, :colors])
  end
end
