# frozen_string_literal: true

class SeedStaffEmailStatusOauthLinked < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute("INSERT INTO staff_email_statuses (id) VALUES (#{StaffEmailStatus::OAUTH_LINKED}) ON CONFLICT DO NOTHING")
    end
  end

  def down
    safety_assured do
      execute("DELETE FROM staff_email_statuses WHERE id = #{StaffEmailStatus::OAUTH_LINKED}")
    end
  end
end
