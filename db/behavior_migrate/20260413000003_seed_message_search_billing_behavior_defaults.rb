# frozen_string_literal: true

class SeedMessageSearchBillingBehaviorDefaults < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      MessageBehaviorEvent.ensure_defaults!
      MessageBehaviorLevel.ensure_defaults!
      SearchBehaviorEvent.ensure_defaults!
      SearchBehaviorLevel.ensure_defaults!
      BillingBehaviorEvent.ensure_defaults!
      BillingBehaviorLevel.ensure_defaults!
    end
  end

  def down
    # Seed data is idempotent; no rollback needed.
  end
end
