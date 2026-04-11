defmodule Crud.Blog.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    many_to_many :posts, Crud.Blog.Post, join_through: "posts_tags", on_replace: :delete
    many_to_many :items, Crud.Product.Item, join_through: "item_tag_relations", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
