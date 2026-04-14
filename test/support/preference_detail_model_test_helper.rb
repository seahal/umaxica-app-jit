# typed: false
# frozen_string_literal: true

module PreferenceDetailModelTestHelper
  def assert_preference_detail_model_behavior(
    model_class:,
    preference:,
    default_option_id:,
    alternative_preference:,
    option:
  )
    record = model_class.new(
      preference: preference,
      option: option,
    )

    assert_predicate record, :valid?

    model_class.create!(
      preference: preference,
      option: option,
    )

    duplicate = model_class.new(
      preference: preference,
      option: option,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:preference_id]

    different_preference = model_class.new(
      preference: alternative_preference,
      option: option,
    )

    assert_predicate different_preference, :valid?

    defaulted = model_class.new(preference: alternative_preference)

    assert_predicate defaulted, :valid?
    assert_equal default_option_id, defaulted.option_id
  end
end
