# frozen_string_literal: true

class AlignStaffOrgPreferencesFkDeleteBehavior < ActiveRecord::Migration[8.2]
  def change
    # Remove existing FK without on_delete
    remove_foreign_key(:staff_org_preferences, :staffs)
    # Add FK with on_delete: :cascade to match model's dependent: :delete_all
    add_foreign_key(:staff_org_preferences, :staffs, on_delete: :cascade, validate: false)
  end
end
