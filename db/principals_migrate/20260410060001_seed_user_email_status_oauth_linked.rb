# frozen_string_literal: true

class SeedUserEmailStatusOauthLinked < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute("INSERT INTO user_email_statuses (id) VALUES (#{UserEmailStatus::OAUTH_LINKED}) ON CONFLICT DO NOTHING")
    end
  end

  def down
    safety_assured do
      execute("DELETE FROM user_email_statuses WHERE id = #{UserEmailStatus::OAUTH_LINKED}")
    end
  end
end
