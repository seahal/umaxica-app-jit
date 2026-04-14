# typed: false
# frozen_string_literal: true

module ReferenceTableValidatable
  extend ActiveSupport::Concern

  class_methods do
    def validates_reference_table(attribute, association:, allow_nil: false)
      validates attribute, numericality: { only_integer: true }, allow_nil: allow_nil

      validate do
        value = public_send(attribute)

        next if value.nil? && allow_nil
        next unless errors[attribute].empty?

        reflection = self.class.reflect_on_association(association)
        unless reflection&.macro == :belongs_to
          raise ArgumentError, "#{self.class.name}##{association} must be a belongs_to association"
        end

        reference_class = reflection.klass
        exists = reference_class.exists?(id: value)

        next if exists

        errors.add(attribute, "must reference an existing #{association}")
      end
    end
  end
end
