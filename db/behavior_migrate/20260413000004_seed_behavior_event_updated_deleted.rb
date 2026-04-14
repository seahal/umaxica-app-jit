# frozen_string_literal: true

class SeedBehaviorEventUpdatedDeleted < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      %w(AppDocumentBehaviorEvent ComDocumentBehaviorEvent OrgDocumentBehaviorEvent
         AppTimelineBehaviorEvent ComTimelineBehaviorEvent OrgTimelineBehaviorEvent).each do |klass_name|
        klass_name.constantize.ensure_defaults!
      end

      %w(AppDocumentBehaviorLevel ComDocumentBehaviorLevel OrgDocumentBehaviorLevel
         AppTimelineBehaviorLevel ComTimelineBehaviorLevel OrgTimelineBehaviorLevel).each do |klass_name|
        klass_name.constantize.ensure_defaults!
      end
    end
  end

  def down
    # Seed data is idempotent; no rollback needed.
  end
end
