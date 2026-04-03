# typed: false
# frozen_string_literal: true

require "test_helper"

class TaxonomyBuilderTest < ActiveSupport::TestCase
  DummyRecord = Struct.new(:id, :parent_id, :name, keyword_init: true)

  test "build_tree creates nested tree from flat records" do
    records = [
      DummyRecord.new(id: 1, parent_id: nil, name: "Root"),
      DummyRecord.new(id: 2, parent_id: 1, name: "Child 1"),
      DummyRecord.new(id: 3, parent_id: 1, name: "Child 2"),
      DummyRecord.new(id: 4, parent_id: 2, name: "Grandchild"),
    ]

    result = TaxonomyBuilder.build_tree(records)

    assert_equal 1, result.size
    assert_equal 1, result.first[:id]
    assert_equal 2, result.first[:children].size
    grandchild = result.first[:children].find { |c| c[:id] == 2 }

    assert_equal 1, grandchild[:children].size
    assert_equal 4, grandchild[:children].first[:id]
  end

  test "build_tree handles hash records" do
    records = [
      { id: "a", parent_id: nil, name: "Root" },
      { id: "b", parent_id: "a", name: "Child" },
    ]

    result = TaxonomyBuilder.build_tree(records)

    assert_equal 1, result.size
    assert_equal "a", result.first[:id]
    assert_equal 1, result.first[:children].size
    assert_equal "b", result.first[:children].first[:id]
  end

  test "build_tree returns empty array for empty input" do
    assert_equal [], TaxonomyBuilder.build_tree([])
  end

  test "build_tree handles single root node" do
    records = [DummyRecord.new(id: 1, parent_id: nil, name: "Only")]
    result = TaxonomyBuilder.build_tree(records)

    assert_equal 1, result.size
    assert_equal 1, result.first[:id]
    assert_equal [], result.first[:children]
  end

  test "build_tree handles multiple root nodes" do
    records = [
      DummyRecord.new(id: 1, parent_id: nil, name: "Root 1"),
      DummyRecord.new(id: 2, parent_id: nil, name: "Root 2"),
    ]

    result = TaxonomyBuilder.build_tree(records)

    assert_equal 2, result.size
    assert_equal [1, 2], result.pluck(:id)
  end
end
