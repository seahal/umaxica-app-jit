# typed: false
# frozen_string_literal: true

module Jit
  module Algorithms
    module TreeBuilder
      module_function

      # Builds a tree structure from a flat list of records
      # @param records [Enumerable] Objects responding to id, parent_id, name (or hash)
      # @return [Array<Hash>] Roots of the tree
      def build(records)
        nodes_by_id = {}
        nodes =
          Array(records).map do |record|
            node = {
              id: extract_value(record, :id),
              parent_id: extract_value(record, :parent_id),
              name: extract_value(record, :name),
              children: [],
            }
            nodes_by_id[node[:id]] = node
            node
          end

        assemble_tree(nodes_by_id, nodes)
      end

      def assemble_tree(nodes_by_id, nodes)
        roots = []

        nodes.each do |node|
          parent = nodes_by_id[node[:parent_id]]

          if parent
            parent[:children] << node
          else
            roots << node
          end
        end

        roots
      end

      def extract_value(record, key)
        if record.is_a?(Hash)
          record[key] || record[key.to_s]
        elsif record.respond_to?(key)
          record.public_send(key)
        end
      end
      private_class_method :assemble_tree, :extract_value
    end
  end
end
