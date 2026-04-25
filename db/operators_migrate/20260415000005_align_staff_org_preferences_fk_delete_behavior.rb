# frozen_string_literal: true

class AlignStaffOrgPreferencesFkDeleteBehavior < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:staff_org_preferences)
    return unless table_exists?(:staffs)
    return unless column_exists?(:staff_org_preferences, :staff_id)

    # Remove existing FK without on_delete
    remove_foreign_key(:staff_org_preferences, :staffs) if foreign_key_exists?(:staff_org_preferences, :staffs)
    # Add FK with on_delete: :cascade to match model's dependent: :delete_all
    add_foreign_key(:staff_org_preferences, :staffs, on_delete: :cascade, validate: false) unless foreign_key_exists?(:staff_org_preferences, :staffs)
  end
end
