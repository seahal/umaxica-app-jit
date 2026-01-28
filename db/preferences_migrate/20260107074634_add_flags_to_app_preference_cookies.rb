# frozen_string_literal: true

class AddFlagsToAppPreferenceCookies < ActiveRecord::Migration[8.2]
  def change
    add_column :app_preference_cookies, :targetable, :boolean, null: false, default: false
    add_column :app_preference_cookies, :performant, :boolean, null: false, default: false
    add_column :app_preference_cookies, :functional, :boolean, null: false, default: false
  end
end
