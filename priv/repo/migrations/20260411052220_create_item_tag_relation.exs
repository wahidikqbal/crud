defmodule Crud.Repo.Migrations.CreateItemTagRelation do
  use Ecto.Migration

  def change do
    create table(:item_tag_relations, primary_key: false) do
      add :item_id, references(:items, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false

    end

    create index(:item_tag_relations, [:item_id])
    create index(:item_tag_relations, [:tag_id])
    create unique_index(:item_tag_relations, [:item_id, :tag_id])
  end
end
