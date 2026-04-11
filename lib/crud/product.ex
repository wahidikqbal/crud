defmodule Crud.Product do
  @moduledoc """
  The Product context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Crud.Repo
  alias Crud.Product.Item
  alias Crud.Blog.Tag

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
    |> Repo.preload([ :category, :tags ])
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id) do
    Repo.get!(Item, id)
    |> Repo.preload([ :category, :tags ])
  end

  # Helper function untuk mengambil tag berdasarkan atribut yang diberikan
  defp tag_from_attrs(attrs) do
    attrs
    |> Map.get("tag_ids", Map.get(attrs, :tag_ids, []))
    |> List.wrap() # Ensure it's a list
    |> Enum.map(&parse_tag_id/1)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> []
      ids -> Repo.all(from t in Tag, where: t.id in ^ids)
    end
  end

  defp parse_tag_id(id) when is_integer(id), do: id

  defp parse_tag_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> int
      _ -> nil
    end
  end

  defp parse_tag_id(_), do: nil

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> put_assoc(:tags, tag_from_attrs(attrs))
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> put_assoc(:tags, tag_from_attrs(attrs))
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    item
    |> item_with_tags()
    |> Item.changeset(attrs)
  end

  defp item_with_tags(%Item{tags: tags} = item) when is_list(tags) do
    %{item | tag_ids: Enum.map(tags, & &1.id)}
  end

  defp item_with_tags(item), do: item
end
