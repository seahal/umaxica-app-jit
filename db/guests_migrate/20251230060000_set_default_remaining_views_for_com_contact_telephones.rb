# frozen_string_literal: true

class SetDefaultRemainingViewsForComContactTelephones < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      change_column_default :com_contact_telephones, :remaining_views, from: 0, to: 10
    end
  end
end
