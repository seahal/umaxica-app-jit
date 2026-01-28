# frozen_string_literal: true

class UserPurgeJob < ApplicationJob
  queue_as :default

  def perform
    users = User.where(status_id: "PENDING_DELETION")
                .where(scheduled_purge_at: ..Time.current)

    users.find_each do |user|
      user.destroy!
    rescue => e
      Rails.logger.error("Failed to purge user #{user.id}: #{e.message}")
    end
  end
end
