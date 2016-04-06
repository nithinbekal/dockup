defmodule Dockup.ProjectIndexTest do
  use ExUnit.Case

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
end
