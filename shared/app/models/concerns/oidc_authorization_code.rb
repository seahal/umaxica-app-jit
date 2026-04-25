# typed: false
# frozen_string_literal: true

require "json"

# Shared behavior for OIDC authorization code models.
# This concern provides common functionality for subject-scoped authorization codes
# including PKCE validation, issue/consume/revoke operations, and state checks.
#
# The subject association name must be defined via the `subject_association_name` class method
# in the including model.
#
# Example:
#   class UserAuthorizationCode < PrincipalRecord
#     include ::OidcAuthorizationCode
#     subject_association_name :user
#   end
#
module OidcAuthorizationCode
  extend ActiveSupport::Concern

  CODE_TTL = 10.seconds
  CODE_BYTES = 32

  class_methods do
    def subject_association_name
      Thread.current[:"#{name}_subject_association_name"] ||= default_subject_association_name
    end

    def subject_association_name=(name)
      Thread.current[:"#{name}_subject_association_name"] = name
    end

    def default_subject_association_name
      name
        .sub("AuthorizationCode", "")
        .underscore
        .to_sym
    end
    private :default_subject_association_name

    def generate_code
      SecureRandom.urlsafe_base64(CODE_BYTES)
    end

    def issue!(client_id:, redirect_uri:, code_challenge:, code_challenge_method: "S256",
               scope: nil, state: nil, nonce: nil, auth_method: nil, acr: nil, subject:)
      create_options = {
        :code => generate_code,
        subject_association_name => subject,
        :client_id => client_id,
        :redirect_uri => redirect_uri,
        :code_challenge => code_challenge,
        :code_challenge_method => code_challenge_method,
        :scope => scope,
        :state => state,
        :nonce => nonce,
        :auth_method => serialize_auth_method(auth_method),
        :acr => acr.to_s.presence || "aal1",
        :varnishable_at => CODE_TTL.from_now,
      }
      create!(create_options)
    end

    private

    def serialize_auth_method(auth_method)
      case auth_method
      when Array
        auth_method.map(&:to_s).compact_blank.to_json
      else
        auth_method.to_s.presence || ""
      end
    end
  end

  included do
    validates :code, presence: true, uniqueness: true, length: { maximum: 64 }
    validates :client_id, presence: true, length: { maximum: 64 }
    validates :redirect_uri, presence: true
    validates :code_challenge, presence: true
    validates :code_challenge_method, inclusion: { in: %w(S256) }, length: { maximum: 8 }
    validates :varnishable_at, presence: true

    scope :valid, -> { where(consumed_at: nil, revoked_at: nil).where("varnishable_at > ?", Time.current) }
  end

  def expired?
    varnishable_at <= Time.current
  end

  def consumed?
    consumed_at.present?
  end

  def revoked?
    revoked_at.present?
  end

  def usable?
    !expired? && !consumed? && !revoked?
  end

  def consume!
    raise RuntimeError, "Authorization code already consumed" if consumed?
    raise RuntimeError, "Authorization code revoked" if revoked?
    raise RuntimeError, "Authorization code expired" if expired?

    update!(consumed_at: Time.current)
  end

  def revoke!
    update!(revoked_at: Time.current) unless revoked?
  end

  def verify_pkce(code_verifier)
    return false if code_verifier.blank?

    expected = Base64.urlsafe_encode64(
      Digest::SHA256.digest(code_verifier),
      padding: false,
    )
    ActiveSupport::SecurityUtils.secure_compare(code_challenge, expected)
  end

  def subject
    public_send(self.class.subject_association_name)
  end

  def subject_id
    public_send("#{self.class.subject_association_name}_id")
  end
end
