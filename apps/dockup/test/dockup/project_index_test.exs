defmodule Dockup.ProjectIndexTest do
  use ExUnit.Case, async: true

  test "it should be possible to write and read project properties" do
    Dockup.ProjectIndex.start("test_dets")

    Dockup.ProjectIndex.write("fake_project_id", {:hello, :world})
    assert Dockup.ProjectIndex.read("non_existent") == nil
    assert Dockup.ProjectIndex.read("fake_project_id") == {:hello, :world}

    File.rm_rf "test_dets"
  end

  test "writing properties for existing project id overwrites existing props" do
    Dockup.ProjectIndex.start("test_dets")

    Dockup.ProjectIndex.write("fake_project_id", {:hello, :world})
    Dockup.ProjectIndex.write("fake_project_id", {:foo, :bar})
    assert Dockup.ProjectIndex.read("fake_project_id") == {:foo, :bar}

    File.rm_rf "test_dets"
  end

  test ".all returns the properties of all projects" do
    Dockup.ProjectIndex.start("test_dets")

    Dockup.ProjectIndex.write("project_1", %{hello: :world})
    Dockup.ProjectIndex.write("project_2", %{foo: :bar})
    assert Dockup.ProjectIndex.all == [%{foo: :bar}, %{hello: :world}]

    File.rm_rf "test_dets"
  end
end
