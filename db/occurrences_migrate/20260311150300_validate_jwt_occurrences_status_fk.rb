# frozen_string_literal: true

class ValidateJwtOccurrencesStatusFk < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:jwt_occurrences, :jwt_occurrence_statuses, name: "fk_jwt_occurrences_on_status_id")
  end
end
