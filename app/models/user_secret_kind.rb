# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_kinds
# Database name: principal
#
#  id :string(255)      not null, primary key
#

class UserSecretKind < PrincipalRecord
  include StringPrimaryKey

  # Lifetime-based kind constants (UPPER_SNAKE_CASE)
  UNLIMITED = "UNLIMITED"
  ONE_TIME = "ONE_TIME"
  TIME_BOUND = "TIME_BOUND"

  ALL = [ UNLIMITED, ONE_TIME, TIME_BOUND ].freeze

  has_many :user_secrets, inverse_of: :user_secret_kind, dependent: :restrict_with_exception

  validates :id, uniqueness: { case_sensitive: false }
  validates :id, format: { with: /\A[A-Z0-9_]+\z/, message: "must be UPPER_SNAKE_CASE" } # rubocop:disable Rails/I18nLocaleTexts
end
