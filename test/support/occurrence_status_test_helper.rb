# frozen_string_literal: true

module OccurrenceStatusTestHelper
  def assert_invalid_attribute(record, attribute)
    assert_not record.valid?
    assert_predicate record.errors[attribute], :present?
  end

  def assert_upcases_id(model_class)
    record = model_class.new(id: "mixed_case")
    record.validate

    assert_equal "MIXED_CASE", record.id
  end

  def assert_status_association(model_class, association_name)
    association = model_class.reflect_on_association(association_name)

    assert_not_nil association
    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
  end
end
