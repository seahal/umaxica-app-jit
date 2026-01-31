# frozen_string_literal: true

module TimelineIntegerTreeTests
  private

  def treeable_class
    raise NotImplementedError, "define `treeable_class` in the including test class"
  end

  def test_defaults_parent_id_to_zero
    master = treeable_class.new

    assert_equal 0, master.parent_id
  end

  def test_root_predicate_matches_zero_parent
    master = treeable_class.new(parent_id: 0)

    assert_predicate master, :root?
  end

  def test_root_predicate_fails_for_nonzero_parent
    master = treeable_class.new(parent_id: 1)

    assert_not master.root?
  end

  def test_tree_root_parent_values_include_root
    values = treeable_class.tree_root_parent_values

    assert_includes values, 0
  end
end
