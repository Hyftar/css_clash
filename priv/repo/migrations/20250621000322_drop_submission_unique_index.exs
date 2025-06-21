defmodule CssClash.Repo.Migrations.DropSubmissionUniqueIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:submissions, [:target_id, :user_id])
  end
end
