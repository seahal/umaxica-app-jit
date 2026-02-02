# frozen_string_literal: true

# CodeIdentifiable concern for status/kind/master tables
# Replaces StringPrimaryKey concern for tables with bigint PK + code column
#
# Usage:
#   class UserStatus < PrincipalRecord
#     include CodeIdentifiable
#
#     NEYO = "NEYO"
#     NONE = "NONE"
#     # ...
#   end
#
# This concern provides:
# - Code validation (presence, uniqueness, format)
# - Code normalization (upcase)
# - Finder methods by code
# - Code-based comparison
module CodeIdentifiable
  extend ActiveSupport::Concern

  included do
    # Normalize code to uppercase before validation
    before_validation { self.code = code&.upcase }

    # Validations
    # Note: citext columns are case-insensitive at DB level, so we use standard uniqueness
    validates :code,
              presence: true,
              length: { maximum: 255 },
              uniqueness: true,
              format: { with: /\A[A-Z0-9_]+\z/, message: :code_format }
  end

  class_methods do
    # Find by code (case-insensitive)
    # @param code [String] the code to search for
    # @return [ActiveRecord::Base, nil]
    def find_by_code(code)
      find_by("UPPER(code) = UPPER(?)", code)
    end

    # Find by code! (raises if not found)
    # @param code [String] the code to search for
    # @return [ActiveRecord::Base]
    # @raise [ActiveRecord::RecordNotFound]
    def find_by_code!(code)
      find_by!("UPPER(code) = UPPER(?)", code)
    end
  end

  # Return code for string representation
  def to_s
    code
  end

  # Compare by code
  def ==(other)
    return super unless other.respond_to?(:code)

    code.to_s.casecmp(other.code.to_s).zero?
  end

  # Compare by code
  def eql?(other)
    self == other
  end

  # Hash by code
  def hash
    code.to_s.upcase.hash
  end
end
