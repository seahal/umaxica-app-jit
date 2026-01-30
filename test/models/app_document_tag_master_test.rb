# == Schema Information
#
# Table name: app_document_tag_masters
# Database name: document
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :string(255)      default("NEYO"), not null
#
# Indexes
#
#  index_app_document_tag_masters_on_lower_id   (lower((id)::text)) UNIQUE
#  index_app_document_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => app_document_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"
require "securerandom"

class AppDocumentTagMasterTest < ActiveSupport::TestCase
  ROOT_SENTINEL = "none"

  # NOTE:
  # - This test file intentionally does not use fixtures (per requirement).
  # - `AppDocumentTagMaster` currently has no `position` column in its schema header.
  #   If a `position` column is added later, the ordering assertions in
  #   `test "subtree_in_tree_order returns a stable tree order"` will automatically
  #   start exercising "position asc, id asc".

  def create_master!(id:, parent: nil, parent_id: nil, position: nil)
    attributes = { id: id }

    if parent
      attributes[:parent] = parent
    elsif parent_id
      attributes[:parent_id] = parent_id
    else
      attributes[:parent_id] = ROOT_SENTINEL
    end

    if AppDocumentTagMaster.column_names.include?("position")
      attributes[:position] = position
    end

    AppDocumentTagMaster.create!(attributes)
  end

  def ensure_root_sentinel!
    return if AppDocumentTagMaster.exists?(id: ROOT_SENTINEL)

    now = Time.current
    # We need a row whose `id` and `parent_id` are the sentinel value to satisfy the
    # self-referential FK on `parent_id`. This sentinel id is intentionally lowercase
    # and would fail `StringPrimaryKey` validations/callbacks, so we insert directly.
    # rubocop:disable Rails/SkipsModelValidations
    AppDocumentTagMaster.insert_all!(
      [{ id: ROOT_SENTINEL, parent_id: ROOT_SENTINEL, created_at: now, updated_at: now }],
    )
    # rubocop:enable Rails/SkipsModelValidations
  end

  def build_tree!
    ensure_root_sentinel!
    token = SecureRandom.hex(4).upcase

    root = create_master!(id: "ROOT_#{token}", parent_id: ROOT_SENTINEL, position: 0)
    a = create_master!(id: "A_#{token}", parent: root, position: 2)
    b = create_master!(id: "B_#{token}", parent: root, position: 1)
    c = create_master!(id: "C_#{token}", parent: root, position: 1)
    c1 = create_master!(id: "C1_#{token}", parent: c, position: 1)

    { root: root, a: a, b: b, c: c, c1: c1 }
  end

  test "basic tree can be constructed (parent/children associations)" do
    tree = build_tree!

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

  test "root?/leaf?判定が正しい" do
    tree = build_tree!

    assert_predicate tree[:root], :root?
    assert_not tree[:b].root?

    assert_not tree[:root].leaf?
    assert_predicate tree[:a], :leaf?
    assert_predicate tree[:b], :leaf?
    assert_not tree[:c].leaf?
    assert_predicate tree[:c1], :leaf?
  end

  test "siblings が正しい (include_self false/true)" do
    tree = build_tree!

    sibling_ids_without_self = tree[:b].siblings(include_self: false).map(&:id)
    sibling_ids_with_self = tree[:b].siblings(include_self: true).map(&:id)

    if AppDocumentTagMaster.column_names.include?("position")
      assert_equal [tree[:c].id, tree[:a].id], sibling_ids_without_self
      assert_equal [tree[:b].id, tree[:c].id, tree[:a].id], sibling_ids_with_self
    else
      assert_equal [tree[:a].id, tree[:c].id], sibling_ids_without_self
      assert_equal [tree[:a].id, tree[:b].id, tree[:c].id], sibling_ids_with_self
    end
  end

  test "subtree_ids / ancestor_ids が正しい (include_self true/false)" do
    tree = build_tree!

    expected_subtree_ids = [tree[:root].id, tree[:a].id, tree[:b].id, tree[:c].id, tree[:c1].id]

    subtree_ids_with_self = AppDocumentTagMaster.subtree_ids(tree[:root].id, include_self: true)
    assert_equal expected_subtree_ids.sort, subtree_ids_with_self.sort

    subtree_ids_without_self = AppDocumentTagMaster.subtree_ids(tree[:root].id, include_self: false)
    assert_equal (expected_subtree_ids - [tree[:root].id]).sort, subtree_ids_without_self.sort

    ancestor_ids_with_self = AppDocumentTagMaster.ancestor_ids(tree[:c1].id, include_self: true)
    assert_equal [tree[:root].id, tree[:c].id, tree[:c1].id], ancestor_ids_with_self

    ancestor_ids_without_self = AppDocumentTagMaster.ancestor_ids(tree[:c1].id, include_self: false)
    assert_equal [tree[:root].id, tree[:c].id], ancestor_ids_without_self
  end

  test "breadcrumb が root->self の順で返る" do
    tree = build_tree!

    assert_equal [tree[:root].id, tree[:c].id, tree[:c1].id], tree[:c1].breadcrumb.map(&:id)
  end

  test "ancestors / descendants が正しい (include_self true/false)" do
    tree = build_tree!

    ancestor_ids_with_self = tree[:c1].ancestors(include_self: true).map(&:id)
    ancestor_ids_without_self = tree[:c1].ancestors(include_self: false).map(&:id)
    assert_equal [tree[:root].id, tree[:c].id, tree[:c1].id], ancestor_ids_with_self
    assert_equal [tree[:root].id, tree[:c].id], ancestor_ids_without_self

    descendant_ids_with_self = tree[:c].descendants(include_self: true).map(&:id)
    descendant_ids_without_self = tree[:c].descendants(include_self: false).map(&:id)
    assert_equal [tree[:c].id, tree[:c1].id], descendant_ids_with_self
    assert_equal [tree[:c1].id], descendant_ids_without_self
  end

  test "subtree_in_tree_order returns a stable tree order" do
    tree = build_tree!

    ids = AppDocumentTagMaster.subtree_in_tree_order(tree[:root].id, include_self: true).pluck(:id)

    if AppDocumentTagMaster.column_names.include?("position")
      # position asc -> id asc
      expected = [tree[:root].id, tree[:b].id, tree[:c].id, tree[:c1].id, tree[:a].id]
      assert_equal expected, ids
    else
      # This model currently has no `position` column, so ordering is by id only.
      expected = [tree[:root].id, tree[:a].id, tree[:b].id, tree[:c].id, tree[:c1].id]
      assert_equal expected, ids
    end
  end

  test "循環参照の validation が効く (self-parent / descendant-parent / 正常変更)" do
    tree = build_tree!

    # self-parent (must be persisted for current validation logic)
    node = tree[:b]
    node.parent_id = node.id
    assert_not node.valid?
    assert_predicate node.errors[:parent_id], :any?

    # descendant-parent (cycle detected)
    root = tree[:root]
    root.parent_id = tree[:c1].id
    assert_not root.valid?
    assert_predicate root.errors[:parent_id], :any?

    # valid parent change
    a = tree[:a]
    a.parent = tree[:c]
    assert_predicate a, :valid?
    a.save!
  end
end
