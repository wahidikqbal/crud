defmodule Crud.PostFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crud.Post` context.
  """

  @doc """
  Generate a unique tag name.
  """
  def unique_tag_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        name: unique_tag_name()
      })
      |> Crud.Post.create_tag()

    tag
  end
end
