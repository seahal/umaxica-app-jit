# typed: false
# frozen_string_literal: true

module Behavior
  extend ActiveSupport::Concern

  included do
    belongs_to :actor, polymorphic: true, optional: true

    validates :subject_id, presence: true
    validates :subject_type, presence: true

    attribute :occurred_at, default: -> { Time.current }

    scope :active, -> {
      where("expires_at IS NULL OR expires_at > ?", Time.current)
    }
  end

  def subject
    subject_type.constantize.find(subject_id) if subject_type.present? && subject_id.present?
  end

  def subject=(record)
    self.subject_type = record.class.name
    self.subject_id = record.id
  end
end
