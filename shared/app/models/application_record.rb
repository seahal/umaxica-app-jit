# typed: false
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include ::ReferenceTableValidatable

  def self.insert_missing_fixed_ids!(ids)
    raise if ids.blank?

    rows = ids.uniq
    rows.map! { |id| { primary_key => id } }

    operation =
      lambda do
        # Validation-free insert is intentional for fixed-id master rows whose required payload is only the primary key.
        begin
          insert_all(
            rows,
            record_timestamps: record_timestamps,
          )
        rescue ArgumentError, ActiveRecord::RecordNotUnique
          # Handle missing unique index or duplicates gracefully during initial setup
          rows.each do |row|
            create!(row) unless exists?(row)
          end
        end
      end

    if defined?(Prosopite)
      Prosopite.pause(&operation)
    else
      operation.call
    end

  end
end
