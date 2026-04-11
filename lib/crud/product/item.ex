defmodule Crud.Product.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :code, :string
    field :tag_ids, {:array, :integer}, virtual: true # Add virtual field for tag IDs

    belongs_to :category, Crud.Blog.Category
    many_to_many :tags, Crud.Blog.Tag, join_through: "item_tag_relations", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :code, :category_id, :tag_ids])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
    |> foreign_key_constraint(:category_id)
  end
end
