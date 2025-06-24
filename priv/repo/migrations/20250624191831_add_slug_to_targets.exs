defmodule CssClash.Repo.Migrations.AddSlugToTargets do
  use Ecto.Migration

  def change do
    alter table(:targets) do
      add :slug, :string
    end

    # Create a unique index on the slug field
    create unique_index(:targets, [:slug])

    # Flush the changes to ensure the column exists
    flush()

    # Execute raw SQL to update existing records with a UUID
    execute """
    UPDATE targets SET slug = gen_random_uuid()
    WHERE slug IS NULL
    """

    # Now make the slug not nullable
    alter table(:targets) do
      modify :slug, :string, null: false
    end
  end
end
