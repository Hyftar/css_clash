defmodule CssClash.Repo.Migrations.CreateTargets do
  use Ecto.Migration

  def change do
    create table(:targets) do
      add :name, :string, null: false
      add :image_data, :binary, null: false
      add :colors, {:array, :string}, null: false, default: []

      timestamps(type: :utc_datetime)
    end

    flush()

    create table(:submissions) do
      add :target_id, references(:targets, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :score, :float, null: true
      add :html, :text, null: false
      add :css, :text, null: false

      timestamps()
    end

    create unique_index(:submissions, [:target_id, :user_id])
  end
end
