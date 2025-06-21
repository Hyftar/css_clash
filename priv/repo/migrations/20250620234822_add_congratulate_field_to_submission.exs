defmodule CssClash.Repo.Migrations.AddCongratulateFieldToSubmission do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :congratulated, :boolean, default: false
    end
  end
end
