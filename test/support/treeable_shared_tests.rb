# frozen_string_literal: true

require "securerandom"

module TreeableSharedTests
  ROOT_SENTINEL = "none"

  private

  def treeable_class
    raise NotImplementedError, "define `treeable_class` in the including test class"
  end

  def ensure_root_sentinel!(klass)
    return if klass.exists?(id: ROOT_SENTINEL)

    now = Time.current
    # We need a row whose `id` and `parent_id` are the sentinel value to satisfy the
    # self-referential FK on `parent_id`. This sentinel id is intentionally lowercase
    # and would fail `StringPrimaryKey` validations/callbacks, so we insert directly.
    # rubocop:disable Rails/SkipsModelValidations
    klass.insert_all!(
      [{ id: ROOT_SENTINEL, parent_id: ROOT_SENTINEL, created_at: now, updated_at: now }],
    )
    # rubocop:enable Rails/SkipsModelValidations
  end

  def create_master!(klass, id:, parent: nil, parent_id: nil, position: nil)
    attributes = { id: id }

    if parent
      attributes[:parent] = parent
    elsif parent_id
      attributes[:parent_id] = parent_id
    else
      attributes[:parent_id] = ROOT_SENTINEL
    end

    if klass.column_names.include?("position")
      attributes[:position] = position
    end

    klass.create!(attributes)
  end

  def build_tree!(klass)
    ensure_root_sentinel!(klass)
    token = SecureRandom.hex(4).upcase

    root = create_master!(klass, id: "ROOT_#{token}", parent_id: ROOT_SENTINEL, position: 0)
    a    = create_master!(klass, id: "A_#{token}", parent: root, position: 2)
    b    = create_master!(klass, id: "B_#{token}", parent: root, position: 1)
    c    = create_master!(klass, id: "C_#{token}", parent: root, position: 1)
    c1   = create_master!(klass, id: "C1_#{token}", parent: c, position: 1)

    { root: root, a: a, b: b, c: c, c1: c1 }
  end

  public

  def test_validates_id_presence_and_uniqueness
    klass = treeable_class
    ensure_root_sentinel!(klass)

    master = klass.new(id: nil, parent_id: ROOT_SENTINEL)
    assert_not master.valid?
    assert_not_empty master.errors[:id]

    token = SecureRandom.hex(4).upcase
    existing = create_master!(klass, id: "EXISTING_#{token}", parent_id: ROOT_SENTINEL)
    duplicate = klass.new(id: existing.id.downcase, parent_id: ROOT_SENTINEL)
    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:id]
  end

  def test_upcases_id_before_validation
    klass = treeable_class
    ensure_root_sentinel!(klass)

    master = klass.new(id: "new_category", parent_id: ROOT_SENTINEL)
    master.valid?
    assert_equal "NEW_CATEGORY", master.id
  end

  def test_validates_id_format
    klass = treeable_class
    ensure_root_sentinel!(klass)

    master = klass.new(id: "INVALID-ID!", parent_id: ROOT_SENTINEL)
    assert_not master.valid?
    assert_not_empty master.errors[:id]
  end

  def test_name_returns_string
    klass = treeable_class
    ensure_root_sentinel!(klass)

    master = klass.new(id: "TEST_CAT", parent_id: ROOT_SENTINEL)
    assert_respond_to master, :name
    assert_kind_of String, master.name
  end

  def test_validates_length_of_id
    klass = treeable_class
    ensure_root_sentinel!(klass)

    record = klass.new(id: "A" * 256, parent_id: ROOT_SENTINEL)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  def test_tree_parent_and_children_associations
    tree = build_tree!(treeable_class)

    assert_nil tree[:root].parent
    assert_equal tree[:root], tree[:b].parent
    assert_equal tree[:root], tree[:c].parent
    assert_equal tree[:c], tree[:c1].parent

    root_child_ids = tree[:root].children.pluck(:id)
    assert_includes root_child_ids, tree[:a].id
    assert_includes root_child_ids, tree[:b].id
    assert_includes root_child_ids, tree[:c].id

    assert_includes tree[:c].children.pluck(:id), tree[:c1].id
  end

  def test_root_and_leaf_predicates
    tree = build_tree!(treeable_class)

    assert_predicate tree[:root], :root?
    assert_not tree[:b].root?

    assert_not tree[:root].leaf?
    assert_predicate tree[:a], :leaf?
    assert_predicate tree[:b], :leaf?
    assert_not tree[:c].leaf?
    assert_predicate tree[:c1], :leaf?
  end

  def test_siblings_include_self_options
    klass = treeable_class
    tree = build_tree!(klass)

    sibling_ids_without_self = tree[:b].siblings(include_self: false).map(&:id)
    sibling_ids_with_self = tree[:b].siblings(include_self: true).map(&:id)

    if klass.column_names.include?("position")
      assert_equal [tree[:c].id, tree[:a].id], sibling_ids_without_self
      assert_equal [tree[:b].id, tree[:c].id, tree[:a].id], sibling_ids_with_self
    else
      assert_equal [tree[:a].id, tree[:c].id], sibling_ids_without_self
      assert_equal [tree[:a].id, tree[:b].id, tree[:c].id], sibling_ids_with_self
    end
  end

  def test_subtree_ids_and_ancestor_ids
    klass = treeable_class
    tree = build_tree!(klass)

    expected_subtree_ids = [tree[:root].id, tree[:a].id, tree[:b].id, tree[:c].id, tree[:c1].id]

    subtree_ids_with_self = klass.subtree_ids(tree[:root].id, include_self: true)
    assert_equal expected_subtree_ids.sort, subtree_ids_with_self.sort

    subtree_ids_without_self = klass.subtree_ids(tree[:root].id, include_self: false)
    assert_equal (expected_subtree_ids - [tree[:root].id]).sort, subtree_ids_without_self.sort

    ancestor_ids_with_self = klass.ancestor_ids(tree[:c1].id, include_self: true)
    assert_equal [tree[:root].id, tree[:c].id, tree[:c1].id], ancestor_ids_with_self

    ancestor_ids_without_self = klass.ancestor_ids(tree[:c1].id, include_self: false)
    assert_equal [tree[:root].id, tree[:c].id], ancestor_ids_without_self
  end

  def test_breadcrumb_order
    tree = build_tree!(treeable_class)
    assert_equal [tree[:root].id, tree[:c].id, tree[:c1].id], tree[:c1].breadcrumb.map(&:id)
  end

  def test_ancestors_and_descendants
    tree = build_tree!(treeable_class)

    ancestor_ids_with_self = tree[:c1].ancestors(include_self: true).map(&:id)
    ancestor_ids_without_self = tree[:c1].ancestors(include_self: false).map(&:id)
    assert_equal [tree[:root].id, tree[:c].id, tree[:c1].id], ancestor_ids_with_self
    assert_equal [tree[:root].id, tree[:c].id], ancestor_ids_without_self

    descendant_ids_with_self = tree[:c].descendants(include_self: true).map(&:id)
    descendant_ids_without_self = tree[:c].descendants(include_self: false).map(&:id)
    assert_equal [tree[:c].id, tree[:c1].id], descendant_ids_with_self
    assert_equal [tree[:c1].id], descendant_ids_without_self
  end

  def test_subtree_in_tree_order_is_stable
    klass = treeable_class
    tree = build_tree!(klass)

    ids = klass.subtree_in_tree_order(tree[:root].id, include_self: true).pluck(:id)

    if klass.column_names.include?("position")
      expected = [tree[:root].id, tree[:b].id, tree[:c].id, tree[:c1].id, tree[:a].id]
      assert_equal expected, ids
    else
      expected = [tree[:root].id, tree[:a].id, tree[:b].id, tree[:c].id, tree[:c1].id]
      assert_equal expected, ids
    end
  end

  def test_cycle_validation
    tree = build_tree!(treeable_class)

    node = tree[:b]
    node.parent_id = node.id
    assert_not node.valid?
    assert_predicate node.errors[:parent_id], :any?

    root = tree[:root]
    root.parent_id = tree[:c1].id
    assert_not root.valid?
    assert_predicate root.errors[:parent_id], :any?

    a = tree[:a]
    a.parent = tree[:c]
    assert_predicate a, :valid?
    a.save!
  end
end
