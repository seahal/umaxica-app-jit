# frozen_string_literal: true

module TaxonomyBuilder
  module_function

  def build(model)
    records = records_from_model(model)
    build_tree(records)
  end

  def records_from_model(model)
    root_id =
      model.tree_root_parent_values.find do |value|
        model.exists?(id: value)
      end

    if root_id
      model.subtree_in_tree_order(root_id, include_self: false)
    else
      model.order(model.primary_key => :asc)
    end
  end

  def build_tree(records)
    nodes_by_id = {}
    nodes =
      Array(records).map do |record|
        node = {
          id: record.id,
          parent_id: record.parent_id,
          name: record.name,
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

  private_class_method :assemble_tree
end
