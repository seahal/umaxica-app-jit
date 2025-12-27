# frozen_string_literal: true

# NOTE: This migration was used to uppercase contact_status and contact_category titles.
# However, due to the refactoring that changed the primary key from 'title' to 'id',
# this migration is now a no-op. The actual schema changes were handled in earlier migrations.
class UppercaseContactStatusesAndCategories < ActiveRecord::Migration[8.0]
  def change
    # No-op migration - schema already updated by earlier refactoring
  end
end
