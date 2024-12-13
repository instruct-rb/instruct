# test/test_serializable_with_version_test.rb
require_relative "../test_helper"
require "yaml"

class TestSerializable < Minitest::Test
  # A simple class to test basic serialization
  class SimpleObject
    include Instruct::Serializable
    def initialize(name = "default", number = 42)
      @name = name
      @number = number
    end
  end

  # A versioned class with a stable class_id and migration logic
  class VersionedObject
    include Instruct::Serializable
    set_instruct_class_id(1002)      # Assign a stable ID
    set_instruct_class_version(2)    # Current schema version is 2

    def initialize
      @old_field = "old_value"
      @new_field = nil
    end

    def self.migrate_data!(data, from:, to:)
      if from < 2
        # Migrate old_field to new_field
        data["new_field"] = data.delete("old_field")
      end
    end
  end

  # A class with cyclic references
  class CyclicObject
    include Instruct::Serializable
    set_instruct_class_id(1003)
    attr_accessor :other
  end

  def test_basic_serialization
    obj = SimpleObject.new("hello", 123)
    data = Instruct::Serializer.dump(obj)
    loaded = Instruct::Serializer.load(
      data,
      permitted_classes: [SimpleObject]
    )

    assert_kind_of SimpleObject, loaded
    assert_equal "hello", loaded.instance_variable_get("@name")
    assert_equal 123, loaded.instance_variable_get("@number")
  end

  def test_versioned_migration
    obj = VersionedObject.new
    yaml_str = Instruct::Serializer.dump(obj)
    old_yaml = yaml_str.gsub("1002@2", "1002@1")

    loaded = Instruct::Serializer.load(
      old_yaml,
      permitted_classes: [VersionedObject]
    )

    # After migration, old_field should become new_field
    assert_equal "old_value", loaded.instance_variable_get("@new_field")
    assert_nil loaded.instance_variable_get("@old_field")
  end

  def test_cyclic_references
    obj1 = CyclicObject.new
    obj2 = CyclicObject.new
    obj1.other = obj2
    obj2.other = obj1

    yaml = YAML.dump(obj1)
    loaded = Instruct::Serializer.load(
      yaml,
    )

    assert_kind_of CyclicObject, loaded
    loaded_other = loaded.instance_variable_get("@other")
    assert_equal loaded, loaded_other.instance_variable_get("@other")
  end

  class OldClass
    include Instruct::Serializable
    def initialize(msg = "hi")
      @msg = msg
    end
  end

  class RenamedClass
    include Instruct::Serializable
    # Simulate original name "OldClass"
    set_instruct_class_id_from_original_name("TestSerializable::OldClass")
    def initialize(msg = "hi")
      @msg = msg
    end
  end

  def test_class_id_changes_with_original_name
    obj = OldClass.new("updated")
    yaml = YAML.dump(obj)

    loaded = Instruct::Serializer.load(
      yaml,
      permitted_classes: [RenamedClass]
    )

    assert_equal "updated", loaded.instance_variable_get("@msg")
  end

  class UnpermittedClass
  end
  def test_unpermitted_class_raises
    obj = RenamedClass.new(UnpermittedClass.new)
    yaml = YAML.dump(obj)
    assert_raises(ArgumentError) do
      Instruct::Serializer.load(yaml)
    end
  end

end
