# frozen_string_literal: true

class FixNewsConsistency < ActiveRecord::Migration[8.2]
  def change
    %i(org com app).each do |prefix|
      # Tags
      add_index "#{prefix}_timeline_tags", "#{prefix}_timeline_tag_master_id"
      add_foreign_key "#{prefix}_timeline_tag_masters", "#{prefix}_timeline_tag_masters", column: :parent_id, if_not_exists: true

      # Categories
      add_index "#{prefix}_timeline_categories", "#{prefix}_timeline_category_master_id", if_not_exists: true
      add_foreign_key "#{prefix}_timeline_category_masters", "#{prefix}_timeline_category_masters", column: :parent_id, if_not_exists: true

      # Status
      add_foreign_key "#{prefix}_timelines", "#{prefix}_timeline_statuses", column: :status_id, if_not_exists: true

      # Cascades
      # Versions
      remove_foreign_key "#{prefix}_timeline_versions", "#{prefix}_timelines", if_exists: true
      add_foreign_key "#{prefix}_timeline_versions", "#{prefix}_timelines", on_delete: :cascade

      # Tags
      remove_foreign_key "#{prefix}_timeline_tags", "#{prefix}_timelines", if_exists: true
      add_foreign_key "#{prefix}_timeline_tags", "#{prefix}_timelines", on_delete: :cascade

      # Categories
      remove_foreign_key "#{prefix}_timeline_categories", "#{prefix}_timelines", if_exists: true
      add_foreign_key "#{prefix}_timeline_categories", "#{prefix}_timelines", on_delete: :cascade
    end
  end
end
