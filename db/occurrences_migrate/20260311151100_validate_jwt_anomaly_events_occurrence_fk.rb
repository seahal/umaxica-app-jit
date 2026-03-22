# frozen_string_literal: true

class ValidateJwtAnomalyEventsOccurrenceFk < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:jwt_anomaly_events, :jwt_occurrences, name: "fk_jwt_anomaly_events_on_jwt_occurrence_id")
  end
end
