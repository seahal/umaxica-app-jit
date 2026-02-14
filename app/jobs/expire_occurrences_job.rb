# frozen_string_literal: true

class ExpireOccurrencesJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 1000

  def perform
    expire_scope(UserOccurrence)
    expire_scope(StaffOccurrence)
  end

  private

  def expire_scope(model_class)
    model_class.active
      .where(created_at: ...1.year.ago)
      .in_batches(of: BATCH_SIZE) do |relation|
        relation.find_each do |occurrence|
          occurrence.update!(status_id: model_class::EXPIRED_STATUS_ID)
        end
      end
  end
end
