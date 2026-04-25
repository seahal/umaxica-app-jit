# typed: false
# frozen_string_literal: true

require "securerandom"

module TaxonomyTestHelper
  ROOT_SENTINEL = 0

  def ensure_root_sentinel!(klass)
    return if klass.exists?(id: ROOT_SENTINEL)

    attributes = { id: ROOT_SENTINEL, parent_id: ROOT_SENTINEL }
    if klass.column_names.include?("created_at")
      now = Time.current
      attributes[:created_at] = now
      attributes[:updated_at] = now if klass.column_names.include?("updated_at")
    end

    klass.insert_all!(
      [attributes],
    )

  end

  def build_taxonomy_tree_for(klass)
    ensure_root_sentinel!(klass)
    root = klass.create!(parent_id: ROOT_SENTINEL)
    a = klass.create!(parent: root)
    b = klass.create!(parent: root)
    c = klass.create!(parent: root)
    c1 = klass.create!(parent: c)

    { root: root, a: a, b: b, c: c, c1: c1 }
  end
end
