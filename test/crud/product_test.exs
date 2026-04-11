defmodule Crud.ProductTest do
  use Crud.DataCase

  alias Crud.Product

  describe "items" do
    alias Crud.Product.Item

    import Crud.ProductFixtures

    @invalid_attrs %{code: nil, name: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Product.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Product.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{code: "some code", name: "some name"}

      assert {:ok, %Item{} = item} = Product.create_item(valid_attrs)
      assert item.code == "some code"
      assert item.name == "some name"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Product.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name"}

      assert {:ok, %Item{} = item} = Product.update_item(item, update_attrs)
      assert item.code == "some updated code"
      assert item.name == "some updated name"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Product.update_item(item, @invalid_attrs)
      assert item == Product.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Product.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Product.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Product.change_item(item)
    end
  end
end
