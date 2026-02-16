# frozen_string_literal: true

module ConsumeOnceToken
  extend ActiveSupport::Concern
  include RefreshTokenShared

  PREFERENCE_REFRESH_TTL = 400.days

  included do
    scope :active, -> { where(revoked_at: nil, compromised_at: nil) }
    scope :unconsumed, -> { where(used_at: nil) }
  end

  class_methods do
    def consume_once_by_digest!(digest:, now: Time.current)
      return nil if digest.blank?

      consumed_at = now
      scope = where(token_digest: digest, used_at: nil, revoked_at: nil, compromised_at: nil)
      scope = scope.where(arel_table[:expires_at].gt(consumed_at))
      target_id = scope.order(:id).limit(1).pick(:id)
      return nil unless target_id

      updated = where(id: target_id, token_digest: digest, used_at: nil, revoked_at: nil, compromised_at: nil)
        .where(arel_table[:expires_at].gt(consumed_at))
        .update_all(used_at: consumed_at, updated_at: consumed_at)
      return nil unless updated == 1

      find_by(id: target_id)
    end

    def rotate!(presented_digest:, device_id:, now: Time.current)
      replacement = nil
      raw_refresh_token = nil

      transaction do
        consumed = consume_once_by_digest!(digest: presented_digest, now: now)
        return nil unless consumed

        replacement = create_rotated_record!(consumed, device_id: device_id, now: now)
        consumed.update!(replaced_by_id: replacement.id)
        raw_refresh_token = replacement.issued_refresh_token
      end

      replacement.issued_refresh_token = raw_refresh_token
      replacement
    end

    private

    def create_rotated_record!(consumed, device_id:, now:)
      new_device_id = device_id.presence || consumed.device_id
      attrs = {
        status_id: consumed.status_id,
        device_id: new_device_id,
        expires_at: now + PREFERENCE_REFRESH_TTL,
        jti: Jit::Security::Jwt::JtiGenerator.generate,
      }

      replacement = create!(attrs)
      raw_refresh_token, verifier = generate_refresh_token(public_id: replacement.public_id)
      replacement.update!(token_digest: digest_refresh_token(verifier))
      migrate_preference_children!(from: consumed, to: replacement)
      replacement.issued_refresh_token = raw_refresh_token
      replacement
    end

    def migrate_preference_children!(from:, to:)
      prefix = from.class.model_name.singular
      %w(cookie region timezone language colortheme).each do |suffix|
        association_name = "#{prefix}_#{suffix}"
        next unless from.respond_to?(association_name)

        child = from.public_send(association_name)
        next unless child&.respond_to?(:preference_id)

        child.update!(preference_id: to.id)
      end
    end
  end

  def replay?
    used_at.present?
  end

  def revoked?
    revoked_at.present? || compromised_at.present?
  end

  attr_accessor :issued_refresh_token
end
