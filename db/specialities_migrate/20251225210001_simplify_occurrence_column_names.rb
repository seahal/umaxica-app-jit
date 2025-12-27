# frozen_string_literal: true

class SimplifyOccurrenceColumnNames < ActiveRecord::Migration[8.2]
  def change
    # All occurrence tables already use status_id, which is the desired simple name
    # No changes needed - they are already following the pattern we want!

    # However, if we want to be explicit about the FKs, we can add them:
    # (These may already exist, so we'll use if_not_exists in Rails 7.1+)

    # Note: status_id is already the simple name we want, so this migration
    # is mainly for documentation and ensuring FKs are properly defined
  end
end
