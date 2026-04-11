defmodule Crud.Product.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :code, :string
    belongs_to :category, Crud.Blog.Category
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :code, :category_id])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
  end
end
