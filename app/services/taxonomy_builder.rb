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
    Jit::Algorithms::TreeBuilder.build(records)
  end
end
