defmodule Editor.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :name, :string
      add :data, :text

      timestamps()
    end
  end
end
