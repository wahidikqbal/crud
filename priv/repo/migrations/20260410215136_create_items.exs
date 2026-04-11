defmodule Crud.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :code, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:items, [:code])
  end
end
