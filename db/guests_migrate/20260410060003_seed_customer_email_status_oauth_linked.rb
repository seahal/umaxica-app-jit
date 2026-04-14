# frozen_string_literal: true

class SeedCustomerEmailStatusOauthLinked < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute("INSERT INTO customer_email_statuses (id) VALUES (#{CustomerEmailStatus::OAUTH_LINKED}) ON CONFLICT DO NOTHING")
    end
  end

  def down
    safety_assured do
      execute("DELETE FROM customer_email_statuses WHERE id = #{CustomerEmailStatus::OAUTH_LINKED}")
    end
  end
end
