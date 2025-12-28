# frozen_string_literal: true

module OccurrenceTestHelper
  PUBLIC_ID_REGEX = /\A[A-Za-z0-9_-]{21}\z/

  def build_occurrence(model_class, body:, public_id: "A" * 21, status_id: "ACTIVE", memo: "memo",
                       generate_public_id: true)
    record = model_class.new(public_id: public_id, body: body, status_id: status_id, memo: memo)
    record.define_singleton_method(:generate_public_id) { nil } unless generate_public_id
    record
  end

  def assert_invalid_attribute(record, attribute)
    assert_not record.valid?
    assert_predicate record.errors[attribute], :present?
  end

  def assert_public_id_generated(record)
    assert record.save
    assert_predicate record.public_id, :present?
    assert_equal 21, record.public_id.length
    assert_match PUBLIC_ID_REGEX, record.public_id
  end

  def assert_public_id_preserved(record, expected)
    assert record.save
    assert_equal expected, record.public_id
  end

  def assert_expires_at_default(record, min_years: 6, max_years: 8)
    now = Time.current

    assert record.save
    record.reload

    assert_predicate record.expires_at, :present?
    assert_operator record.expires_at, :>, now + min_years.years
    assert_operator record.expires_at, :<, now + max_years.years
  end
end
