defmodule CssClash.TargetsTest do
  use CssClash.DataCase

  alias CssClash.Targets

  describe "targets" do
    alias CssClash.Targets.Target

    import CssClash.TargetsFixtures

    @invalid_attrs %{name: nil, colors: nil, image_data: nil}

    test "list_targets/0 returns all targets" do
      target = target_fixture()
      assert Targets.list_targets() == [target]
    end

    test "get_target!/1 returns the target with given id" do
      target = target_fixture()
      assert Targets.get_target!(target.id) == target
    end

    test "create_target/1 with valid data creates a target" do
      valid_attrs = %{name: "some name", colors: ["#fff", "#ccc"], image_data: "some image_data"}

      assert {:ok, %Target{} = target} = Targets.create_target(valid_attrs)
      assert target.name == "some name"
      assert target.colors == ["#fff", "#ccc"]
      assert target.image_data == "some image_data"
    end

    test "create_target/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Targets.create_target(@invalid_attrs)
    end

    test "update_target/2 with valid data updates the target" do
      target = target_fixture()

      update_attrs = %{
        name: "some updated name",
        colors: ["option1"],
        image_data: "some updated image_data"
      }

      assert {:ok, %Target{} = target} = Targets.update_target(target, update_attrs)
      assert target.name == "some updated name"
      assert target.colors == ["option1"]
      assert target.image_data == "some updated image_data"
    end

    test "update_target/2 with invalid data returns error changeset" do
      target = target_fixture()
      assert {:error, %Ecto.Changeset{}} = Targets.update_target(target, @invalid_attrs)
      assert target == Targets.get_target!(target.id)
    end

    test "delete_target/1 deletes the target" do
      target = target_fixture()
      assert {:ok, %Target{}} = Targets.delete_target(target)
      assert_raise Ecto.NoResultsError, fn -> Targets.get_target!(target.id) end
    end

    test "change_target/1 returns a target changeset" do
      target = target_fixture()
      assert %Ecto.Changeset{} = Targets.change_target(target)
    end
  end
end
