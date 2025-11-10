# frozen_string_literal: true

require "digest"

class EmailPreferenceRequest < UniversalRecord
  CONTEXTS = %w[app org].freeze
  DEFAULT_PREFERENCES = {
    "product_updates" => true,
    "promotional_messages" => true
  }.freeze
  BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

  attr_accessor :raw_token

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :context, presence: true, inclusion: { in: CONTEXTS }
  validates :token_digest, presence: true
  validates :token_expires_at, presence: true

  before_validation :assign_token, :assign_expiry, :ensure_preferences, on: :create

  scope :for_context, ->(context) { where(context: context.to_s) }

  def self.find_by_token(context, token)
    return if token.blank?

    digest = digest_token(token)
    for_context(context).find_by(token_digest: digest)
  end

  def token_valid?
    token_used_at.blank? && token_expires_at.present? && token_expires_at > Time.current
  end

  def preferences_with_defaults
    normalized_preferences(preferences || {}).transform_keys(&:to_sym)
  end

  def mark_preferences!(settings)
    update(
      preferences: normalized_preferences(settings),
      token_used_at: Time.current
    )
  end

  def self.digest_token(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  private

  def assign_token
    return if token_digest.present?

    self.raw_token = SecureRandom.urlsafe_base64(32)
    self.token_digest = self.class.digest_token(raw_token)
  end

  def assign_expiry
    self.token_expires_at ||= 2.hours.from_now
  end

  def ensure_preferences
    self.preferences = normalized_preferences(preferences || {})
  end

  def normalized_preferences(source)
    hash = source.respond_to?(:to_h) ? source.to_h : {}

    DEFAULT_PREFERENCES.each_with_object({}) do |(key, default_value), memo|
      raw_value = if hash.key?(key)
                    hash[key]
      elsif hash.key?(key.to_sym)
                    hash[key.to_sym]
      else
                    default_value
      end

      memo[key] = BOOLEAN_TYPE.cast(raw_value)
    end
  end
end
