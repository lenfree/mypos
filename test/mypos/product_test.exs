defmodule Mypos.ProductTest do
  use Mypos.DataCase, async: true

  alias Mypos.Product

  describe "categories" do
    alias Mypos.Product.Category

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Product.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Product.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Product.create_category(@valid_attrs)
      assert category.description == "some description"
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Product.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Product.update_category(category, @update_attrs)
      assert category.description == "some updated description"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Product.update_category(category, @invalid_attrs)
      assert category == Product.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Product.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Product.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Product.change_category(category)
    end
  end

  describe "items" do
    alias Mypos.Product.{Item, Category}

    @valid_attrs %{
      added_on: ~D[2010-04-17],
      description: "some description",
      name: "some name",
      price: 42
    }
    @update_attrs %{
      added_on: ~D[2011-05-18],
      description: "some updated description",
      name: "some updated name",
      price: 43
    }
    @invalid_attrs %{added_on: nil, description: nil, name: nil, price: nil}

    test "list_items/0 returns all items" do
      category = category_fixture(%{name: "hello"})
      item = item_fixture(%{category_id: category_fixture().id})
      assert 1 == Enum.count(Product.list_items())
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Product.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Product.create_item(@valid_attrs)
      assert item.added_on == ~D[2010-04-17]
      assert item.description == "some description"
      assert item.name == "some name"
      assert Decimal.to_string(item.price) == "42"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Product.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Product.update_item(item, @update_attrs)
      assert item.added_on == ~D[2011-05-18]
      assert item.description == "some updated description"
      assert item.name == "some updated name"
      assert Decimal.to_string(item.price) == "43"
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
