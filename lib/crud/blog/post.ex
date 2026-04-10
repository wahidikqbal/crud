defmodule Crud.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :string
    belongs_to :category, Crud.Blog.Category
    many_to_many :tags, Crud.Blog.Tag, join_through: "posts_tags", on_replace: :delete
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :category_id])
    |> validate_required([:title, :body])
  end
end
