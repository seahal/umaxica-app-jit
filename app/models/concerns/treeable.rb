# frozen_string_literal: true

module Treeable
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_tree_parent_id
    validate :tree_parent_must_not_create_cycle

    prepend InstanceMethods
  end

  module InstanceMethods
    def root?
      self.class.tree_root_parent_values.include?(tree_parent_id_raw)
    end

    def leaf?
      !children_exists?
    end

    def siblings(include_self: false)
      parent_col = tree_parent_column
      raw_parent = tree_parent_id_raw

      relation =
        self.class
          .where(parent_col => raw_parent)
          .then { |r| self.class.tree_order_scope(r) }

      include_self ? relation : relation.where.not(self.class.primary_key => id)
    end

    def ancestors(include_self: false)
      ids = self.class.ancestor_ids(id, include_self: include_self)
      self.class.tree_relation_in_ids_order(ids)
    end

    def descendants(include_self: false)
      self.class.subtree_in_tree_order(id, include_self: include_self)
    end

    def breadcrumb
      ancestors(include_self: true)
    end

    # When `parent_id` is a sentinel (e.g. "none"), the belongs_to association would
    # otherwise try to resolve a record with that id. Treat it as `nil` to avoid
    # mis-resolution and unnecessary queries.
    def parent
      return nil if self.class.tree_root_parent_values.include?(tree_parent_id_raw)

      super
    end

    private

    def children_exists?
      if respond_to?(:children)
        children.exists?
      else
        self.class.exists?(tree_parent_column => id)
      end
    end

    def tree_parent_id_raw
      self[tree_parent_column]
    end
  end

  class_methods do
    # Override by defining this in the model.
    def tree_parent_column = "parent_id"

    # Root sentinel value stored in the parent column.
    #
    def tree_root_parent_value = "none"

    # Accept multiple root sentinel values for compatibility across models/tables.
    # The default supports both legacy ("NEYO") and current ("none") sentinels.
    def tree_root_parent_values
      [tree_root_parent_value, "NEYO", "none"].uniq
    end

    # Sibling order: prefers `position` when present; otherwise uses `id`.
    def tree_order_column
      column_names.include?("position") ? "position" : nil
    end

    def tree_order_scope(relation)
      pk = primary_key
      order_col = tree_order_column

      if order_col
        relation.order(Arel.sql("#{order_col} ASC NULLS LAST"), pk => :asc)
      else
        relation.order(pk => :asc)
      end
    end

    def tree_relation_in_ids_order(ids)
      return none if ids.blank?

      pk = primary_key
      quoted = ids.map { |v| connection.quote(v) }.join(",")
      where(pk => ids).order(Arel.sql("array_position(ARRAY[#{quoted}]::text[], #{table_name}.#{pk}::text)"))
    end

    # Descendant ids (including self).
    def subtree_ids(root_id, include_self: true, max_depth: nil)
      parent = tree_parent_column
      root_vals = tree_root_parent_values
      quoted_root_vals = root_vals.map { |v| connection.quote(v) }.join(",")
      exclude_sentinels = "id NOT IN (#{quoted_root_vals})"

      if root_vals.include?(root_id)
        # Treat passing the sentinel as "roots"; including self in this case is ambiguous,
        # so behave like `include_self: false` and start from root nodes.
        include_self = false
      end

      quoted_root_id = connection.quote(root_id)
      where_anchor = include_self ? "id = #{quoted_root_id}" : "#{parent} = #{quoted_root_id}"
      where_anchor = "(#{where_anchor} AND #{exclude_sentinels})"
      depth_guard = max_depth ? "WHERE tree.depth < #{Integer(max_depth)}" : ""

      # rubocop:disable I18n/RailsI18n/DecorateString
      sql = <<~SQL.squish
        WITH RECURSIVE tree AS (
          SELECT id, #{parent}, 0 AS depth
          FROM #{table_name}
          WHERE #{where_anchor}

          UNION ALL

          SELECT t.id, t.#{parent}, tree.depth + 1
          FROM #{table_name} t
          JOIN tree ON t.#{parent} = tree.id
          #{depth_guard}
        )
        SELECT id FROM tree;
      SQL
      # rubocop:enable I18n/RailsI18n/DecorateString

      connection.exec_query(sql, "subtree_ids").rows.flatten
    end

    # Ancestor ids (including self).
    def ancestor_ids(node_id, include_self: true, max_depth: nil)
      parent = tree_parent_column
      root_vals = tree_root_parent_values
      quoted_root_vals = root_vals.map { |v| connection.quote(v) }.join(",")
      exclude_sentinels = "id NOT IN (#{quoted_root_vals})"
      quoted_node_id = connection.quote(node_id)
      where_anchor =
        if include_self
          "id = #{quoted_node_id}"
        else
          "id = (SELECT #{parent} FROM #{table_name} WHERE id = #{quoted_node_id})"
        end
      where_anchor = "(#{where_anchor} AND #{exclude_sentinels})"
      depth_guard = max_depth ? " AND tree.depth < #{Integer(max_depth)}" : ""
      # rubocop:disable I18n/RailsI18n/DecorateString
      step_where = "WHERE tree.#{parent} NOT IN (#{quoted_root_vals})#{depth_guard}"
      # rubocop:enable I18n/RailsI18n/DecorateString

      # rubocop:disable I18n/RailsI18n/DecorateString
      sql = <<~SQL.squish
        WITH RECURSIVE tree AS (
          SELECT id, #{parent}, 0 AS depth
          FROM #{table_name}
          WHERE #{where_anchor}

          UNION ALL

          SELECT p.id, p.#{parent}, tree.depth + 1
          FROM #{table_name} p
          JOIN tree ON tree.#{parent} = p.id
          #{step_where}
        )
        SELECT id FROM tree
        ORDER BY depth DESC;
      SQL
      # rubocop:enable I18n/RailsI18n/DecorateString

      connection.exec_query(sql, "ancestor_ids").rows.flatten
    end

    # Returns a subtree ordered "by tree order" (prefers `position`) as a Relation.
    #
    # - Builds `path` in the CTE and `ORDER BY path`
    # - Stores id as text in `path` (normalizes String/UUID/Integer)
    # - Stores position as integer in `path` (if missing, uses id only)
    # - Returns a Relation preserving the `ids` order
    def subtree_in_tree_order(root_id, include_self: true, max_depth: nil)
      parent = tree_parent_column
      order = tree_order_column
      root_vals = tree_root_parent_values
      quoted_root_vals = root_vals.map { |v| connection.quote(v) }.join(",")
      exclude_sentinels = "id NOT IN (#{quoted_root_vals})"
      quoted_root_id = connection.quote(root_id)

      include_self = false if include_self && root_vals.include?(root_id)
      where_anchor = include_self ? "id = #{quoted_root_id}" : "#{parent} = #{quoted_root_id}"
      where_anchor = "(#{where_anchor} AND #{exclude_sentinels})"
      depth_guard = max_depth ? "WHERE tree.depth < #{Integer(max_depth)}" : ""

      anchor_path =
        if order
          "ARRAY[ROW(#{order}::int, id::text)]::record[]"
        else
          "ARRAY[ROW(id::text)]::record[]"
        end

      step_path =
        if order
          "tree.path || ARRAY[ROW(t.#{order}::int, t.id::text)]::record[]"
        else
          "tree.path || ARRAY[ROW(t.id::text)]::record[]"
        end

      # rubocop:disable I18n/RailsI18n/DecorateString
      sql = <<~SQL.squish
        WITH RECURSIVE tree AS (
          SELECT
            #{table_name}.*,
            0 AS depth,
            #{anchor_path} AS path
          FROM #{table_name}
          WHERE #{where_anchor}

          UNION ALL

          SELECT
            t.*,
            tree.depth + 1 AS depth,
            #{step_path} AS path
          FROM #{table_name} t
          JOIN tree ON t.#{parent} = tree.id
          #{depth_guard}
        )
        SELECT id
        FROM tree
        ORDER BY path;
      SQL
      # rubocop:enable I18n/RailsI18n/DecorateString

      ids = connection.exec_query(sql, "subtree_in_tree_order_ids").rows.flatten

      # Preserve `ids` order using Postgres `array_position`.
      quoted = ids.map { |v| connection.quote(v) }.join(",")
      order_sql =
        "array_position(ARRAY[#{quoted}]::text[], #{table_name}.#{primary_key}::text)"
      where(primary_key => ids).order(Arel.sql(order_sql))
    end
  end

  # ---- instance side ----

  delegate :tree_parent_column, to: :class

  def normalize_tree_parent_id
    parent_col = tree_parent_column
    root_val = self.class.tree_root_parent_value
    raw = self[parent_col]

    # Normalize blank values to the configured sentinel.
    if raw.blank?
      self[parent_col] = root_val
    end
  end

  def tree_parent_must_not_create_cycle
    parent_col = tree_parent_column
    pid = self[parent_col]
    root_vals = self.class.tree_root_parent_values

    return if pid.blank?
    return if root_vals.include?(pid)
    return if persisted? && !will_save_change_to_attribute?(parent_col)

    if persisted? && pid == id
      errors.add(parent_col, "cannot be self")
      return
    end

    # New records do not have an `id`, so cycle detection is not possible (self-check is enough).
    return unless persisted?

    # If parent is within this node's descendants, it creates a cycle.
    descendant_ids = self.class.subtree_ids(id, include_self: true)
    errors.add(parent_col, "cannot be a descendant (cycle detected)") if descendant_ids.include?(pid)
  end
end
