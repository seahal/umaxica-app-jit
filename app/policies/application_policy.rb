# typed: false
# frozen_string_literal: true

# Base policy class for authorization using Action Policy.
# Provides common authorization patterns for both User and Staff actors.
#
# Inherits from ActionPolicy::Base for caching, scoping, and rule resolution.
# The authorization subject is exposed as both `user` (Action Policy convention)
# and `actor` (project convention, supports User and Staff).
#
# == Initialization
#
# Supports two call styles during the transition period:
#
#   # Legacy style (current tests and internal callers):
#   SomePolicy.new(actor, record)
#
#   # Action Policy style (future preference):
#   SomePolicy.new(record, user: actor)
#
# == Scoping
#
# The inner `Scope` class is a transitional plain-Ruby scope, not an Action Policy
# `scope_for` block. Migrate individual policies to `scope_for :relation` as needed.
class ApplicationPolicy < ActionPolicy::Base
  # Declare the authorization subject as optional so policies can be instantiated
  # without a user (e.g., in tests or unauthenticated contexts).
  authorize :user, optional: true

  # Project-wide alias: `actor` refers to the authorization subject (User or Staff).
  alias_method :actor, :user

  # Accept both call styles:
  #   Legacy (actor, record)  - two positional args
  #   Action Policy (record, user:) - one positional arg + keyword
  def initialize(*args, **params)
    case args.length
    when 2
      # Legacy style: Policy.new(actor, record)
      actor_arg, record_arg = args
      super(record_arg, user: actor_arg, **params)
    when 1
      # Action Policy style: Policy.new(record) or Policy.new(record, user: actor)
      super(args.first, **params)
    else
      super(nil, **params)
    end
  end

  # Default permissions - deny all by default (allowlist approach)
  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  protected

  # @return [Object, nil]
  def organization
    @organization ||=
      if record.respond_to?(:organization)
        record.organization
      elsif record.respond_to?(:organization_id)
        record.organization_id
      end
  end

  # Extract JWT scopes from Current.token (set by authentication)
  # @return [Array<String>]
  def jwt_scopes
    return [] if Current.token.blank?

    Auth::TokenClaims.scopes(Current.token)
  end

  # @param scope [String] the scope to check (e.g., "read:self", "write:org")
  # @return [Boolean]
  def has_scope?(scope)
    jwt_scopes.include?(scope.to_s)
  end

  # @param allowed_domains [Array<String>] list of allowed domain prefixes (e.g., ["app", "org"])
  # @return [Boolean]
  def domain_permitted?(*allowed_domains)
    return true if allowed_domains.blank?

    domain = extract_domain_from_audience
    return true if domain.blank?

    allowed_domains.map(&:to_s).include?(domain.to_s)
  end

  def extract_domain_from_audience
    return nil if Current.token.blank?

    audiences = Array(Current.token["aud"])
    return nil if audiences.empty?

    audiences.first.to_s.split(".").first
  end

  # @return [Object, nil]
  def jwt_subject
    return nil if Current.token.blank?

    Auth::TokenClaims.subject(Current.token)
  end

  def domain_app?
    extract_domain_from_audience == "app"
  end

  def domain_org?
    extract_domain_from_audience == "org"
  end

  def domain_com?
    extract_domain_from_audience == "com"
  end

  # @return [Boolean]
  def owner?
    return false unless actor

    if actor.is_a?(User) && record.respond_to?(:user_id)
      record.user_id == actor.id
    elsif actor.is_a?(Staff) && record.respond_to?(:staff_id)
      record.staff_id == actor.id
    else
      false
    end
  end

  def operator?
    actor&.has_role?("operator", organization: organization)
  end

  def manager?
    actor&.has_role?("manager", organization: organization)
  end

  def editor?
    actor&.has_role?("editor", organization: organization)
  end

  def contributor?
    actor&.has_role?("contributor", organization: organization)
  end

  def viewer?
    actor&.has_role?("viewer", organization: organization)
  end

  def operator_or_manager?
    actor&.operator_or_manager?(organization: organization)
  end

  def can_edit?
    actor&.can_edit?(organization: organization)
  end

  def can_view?
    actor&.can_view?(organization: organization)
  end

  def can_contribute?
    actor&.can_contribute?(organization: organization)
  end

  # Transitional plain-Ruby scope class.
  # Not an Action Policy scope_for block - migrate to `scope_for :relation` per policy as needed.
  class Scope
    attr_reader :actor, :scope

    def initialize(actor, scope)
      @actor = actor
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    protected

    def has_role?(role_key, organization: nil)
      actor&.has_role?(role_key, organization: organization)
    end

    def operator_or_manager?(organization: nil)
      actor&.operator_or_manager?(organization: organization)
    end
  end
end
