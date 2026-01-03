# frozen_string_literal: true

class RemoveTimestampsFromContactCategories < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_timestamps :app_contact_categories
      remove_timestamps :com_contact_categories
      remove_timestamps :org_contact_categories
    end
  end
end
