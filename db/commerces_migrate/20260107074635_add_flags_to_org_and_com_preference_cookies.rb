# frozen_string_literal: true

class AddFlagsToOrgAndComPreferenceCookies < ActiveRecord::Migration[8.2]
  def change
    add_column(:org_preference_cookies, :targetable, :boolean, null: false, default: false)
    add_column(:org_preference_cookies, :performant, :boolean, null: false, default: false)
    add_column(:org_preference_cookies, :functional, :boolean, null: false, default: false)

    add_column(:com_preference_cookies, :targetable, :boolean, null: false, default: false)
    add_column(:com_preference_cookies, :performant, :boolean, null: false, default: false)
    add_column(:com_preference_cookies, :functional, :boolean, null: false, default: false)
  end
end
