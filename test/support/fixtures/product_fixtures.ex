defmodule Crud.ProductFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crud.Product` context.
  """

  @doc """
  Generate a unique item code.
  """
  def unique_item_code, do: "some code#{System.unique_integer([:positive])}"

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        code: unique_item_code(),
        name: "some name"
      })
      |> Crud.Product.create_item()

    item
  end
end
