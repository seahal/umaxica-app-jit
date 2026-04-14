# frozen_string_literal: true

class SeedContactBehaviorModelsNothingZero < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      %w(App Com Org).each do |prefix|
        klass_event = "#{prefix}ContactBehaviorEvent".constantize
        klass_level = "#{prefix}ContactBehaviorLevel".constantize
        klass_event.ensure_defaults!
        klass_level.ensure_defaults!
      end
    end
  end

  def down
    # Seed data is idempotent; no rollback needed.
  end
end
