# frozen_string_literal: true

require "test_helper"
require "jit/algorithms/tree_builder"

module Jit
  module Algorithms
    class TreeBuilderTest < ActiveSupport::TestCase
      Node = Struct.new(:id, :parent_id, :name)

      setup do
        @records = [
          Node.new(1, nil, "Root"),
          Node.new(2, 1, "Child 1"),
          Node.new(3, 1, "Child 2"),
          Node.new(4, 2, "Grandchild 1"),
        ].freeze
      end

      test "builds a tree with correct root and size" do
        tree = TreeBuilder.build(@records)
        assert_equal 1, tree.size
        assert_equal 1, tree.first[:id]
        assert_equal "Root", tree.first[:name]
      end

      test "builds correct children structure" do
        tree = TreeBuilder.build(@records)
        root = tree.first
        assert_equal 2, root[:children].size

        child1 = root[:children].find { |c| c[:id] == 2 }
        child2 = root[:children].find { |c| c[:id] == 3 }

        assert_equal "Child 1", child1[:name]
        assert_equal "Child 2", child2[:name]
      end

      test "builds deep relationships" do
        tree = TreeBuilder.build(@records)
        root = tree.first
        child1 = root[:children].find { |c| c[:id] == 2 }

        assert_equal 1, child1[:children].size
        grandchild = child1[:children].first
        assert_equal 4, grandchild[:id]
        assert_equal "Grandchild 1", grandchild[:name]
        assert_empty grandchild[:children]
      end

      test "handles multiple roots" do
        records = [
          Node.new(1, nil, "Root 1"),
          Node.new(2, nil, "Root 2"),
        ]

        tree = TreeBuilder.build(records)
        assert_equal 2, tree.size
        assert_equal [1, 2], tree.pluck(:id).sort
      end

      test "handles empty input" do
        assert_empty TreeBuilder.build([])
        assert_empty TreeBuilder.build(nil)
      end
    end
  end
end
