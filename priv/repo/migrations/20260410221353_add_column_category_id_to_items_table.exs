defmodule Crud.Repo.Migrations.AddColumnCategoryIdToItemsTable do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :category_id, references(:categories, on_delete: :nothing)
    end

    create index(:items, [:category_id])
  end
end
