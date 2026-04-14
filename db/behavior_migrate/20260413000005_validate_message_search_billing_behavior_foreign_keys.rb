# frozen_string_literal: true

class ValidateMessageSearchBillingBehaviorForeignKeys < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key "message_behaviors", "message_behavior_events"
    validate_foreign_key "message_behaviors", "message_behavior_levels"
    validate_foreign_key "search_behaviors", "search_behavior_events"
    validate_foreign_key "search_behaviors", "search_behavior_levels"
    validate_foreign_key "billing_behaviors", "billing_behavior_events"
    validate_foreign_key "billing_behaviors", "billing_behavior_levels"
  end
end