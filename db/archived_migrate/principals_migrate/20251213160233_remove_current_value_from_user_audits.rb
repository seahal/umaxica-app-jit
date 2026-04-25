# frozen_string_literal: true

class RemoveCurrentValueFromUserAudits < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column(:user_identity_audits, :current_value, :text)
    end
  end
end
