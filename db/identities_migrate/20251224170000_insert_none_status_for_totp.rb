# frozen_string_literal: true

class InsertNoneStatusForTotp < ActiveRecord::Migration[8.2]
  def change
    # Insert NONE status if missing, to satisfy FK for default
    up_only do
      execute("INSERT INTO user_identity_one_time_password_statuses (id) VALUES ('NONE') ON CONFLICT DO NOTHING")
    end
  end
end
