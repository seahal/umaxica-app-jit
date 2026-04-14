# typed: false
# frozen_string_literal: true

class UnchangedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    return unless record.persisted?

    return unless record.will_save_change_to_attribute?(attribute)

    record.errors.add(attribute, options[:message] || :unchanged)

  end
end
