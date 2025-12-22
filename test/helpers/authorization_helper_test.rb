require "test_helper"

class AuthorizationHelperTest < ActionView::TestCase
  class DummyActor
    def initialize(roles: {}, permissions: {})
      @roles = roles
      @permissions = permissions
    end

    def has_role?(role_key, organization: nil)
      @roles.fetch([ role_key, organization ], false)
    end

    def has_any_role?(*role_keys, organization: nil)
      role_keys.any? { |key| has_role?(key, organization: organization) }
    end

    def can_edit?(organization: nil)
      @permissions.fetch([ :edit, organization ], false)
    end

    def can_view?(organization: nil)
      @permissions.fetch([ :view, organization ], false)
    end

    def can_contribute?(organization: nil)
      @permissions.fetch([ :contribute, organization ], false)
    end
  end

  class PolicyStub
    def initialize(result)
      @result = result
    end

    def show?
      @result
    end
  end

  setup do
    extend AuthorizationHelper
  end

  def current_user
    @current_user
  end

  def current_staff
    @current_staff
  end

  def policy(record)
    record.policy
  end

  test "authorized? returns false without current actor" do
    record = OpenStruct.new(policy: PolicyStub.new(true))

    assert_not authorized?(record, :show?)
  end

  test "authorized? uses policy result when actor exists" do
    @current_user = DummyActor.new
    record = OpenStruct.new(policy: PolicyStub.new(true))

    assert authorized?(record, :show?)
  end

  test "authorized? returns false when policy is missing" do
    @current_user = DummyActor.new
    define_singleton_method(:policy) { |_record| raise Pundit::NotDefinedError }

    assert_not authorized?(Object.new, :show?)
  end

  test "current_actor prefers current_user over current_staff" do
    @current_user = DummyActor.new
    @current_staff = DummyActor.new

    assert_equal @current_user, send(:current_actor)
  end

  test "has_role? delegates to current actor" do
    @current_user = DummyActor.new(roles: { [ "admin", nil ] => true })

    assert has_role?("admin")
  end

  test "has_role? returns false if actor has no role" do
    @current_user = DummyActor.new(roles: { [ "admin", nil ] => false })

    assert_not has_role?("admin")
  end

  test "has_role? returns false without current actor" do
    assert_not has_role?("admin")
  end

  test "has_role? with organization scope" do
    org = "organization"
    @current_user = DummyActor.new(roles: { [ "admin", org ] => true })

    assert has_role?("admin", organization: org)
    assert_not has_role?("admin")
  end

  test "has_any_role? delegates to current actor" do
    @current_user = DummyActor.new(roles: { [ "editor", nil ] => true })

    assert has_any_role?("admin", "editor")
  end

  test "has_any_role? returns false if actor has no matching roles" do
    @current_user = DummyActor.new(roles: { [ "guest", nil ] => true })

    assert_not has_any_role?("admin", "editor")
  end

  test "has_any_role? returns false without current actor" do
    assert_not has_any_role?("admin", "editor")
  end

  test "admin? checks for admin role" do
    @current_user = DummyActor.new(roles: { [ "admin", nil ] => true })

    assert_predicate self, :admin?
  end

  test "admin? returns false for non-admin" do
    @current_user = DummyActor.new(roles: { [ "admin", nil ] => false })

    assert_not_predicate self, :admin?
  end

  test "current_actor returns current_staff when user is missing" do
    @current_staff = DummyActor.new

    assert_equal @current_staff, send(:current_actor)
  end

  test "current_actor returns nil when both are missing" do
    assert_nil send(:current_actor)
  end

  test "admin_or_manager? checks role keys" do
    @current_user = DummyActor.new(roles: { [ "manager", nil ] => true })

    assert_predicate self, :admin_or_manager?
  end

  test "admin_or_manager? returns false for other roles" do
    @current_user = DummyActor.new(roles: { [ "guest", nil ] => true })

    assert_not_predicate self, :admin_or_manager?
  end

  test "can_edit? delegates to current actor" do
    @current_user = DummyActor.new(permissions: { [ :edit, nil ] => true })

    assert_predicate self, :can_edit?
  end

  test "can_edit? returns false if not permitted" do
    @current_user = DummyActor.new(permissions: { [ :edit, nil ] => false })

    assert_not_predicate self, :can_edit?
  end

  test "can_view? delegates to current actor" do
    @current_user = DummyActor.new(permissions: { [ :view, nil ] => true })

    assert_predicate self, :can_view?
  end

  test "can_view? returns false if not permitted" do
    @current_user = DummyActor.new(permissions: { [ :view, nil ] => false })

    assert_not_predicate self, :can_view?
  end

  test "can_contribute? delegates to current actor" do
    @current_user = DummyActor.new(permissions: { [ :contribute, nil ] => true })

    assert_predicate self, :can_contribute?
  end

  test "can_contribute? returns false if not permitted" do
    @current_user = DummyActor.new(permissions: { [ :contribute, nil ] => false })

    assert_not_predicate self, :can_contribute?
  end

  test "if_authorized yields when authorized" do
    @current_user = DummyActor.new
    record = OpenStruct.new(policy: PolicyStub.new(true))

    assert_equal "ok", if_authorized(record, :show?) { "ok" }
  end

  test "if_authorized does not yield when not authorized" do
    @current_user = DummyActor.new
    record = OpenStruct.new(policy: PolicyStub.new(false))
    yielded = false
    if_authorized(record, :show?) { yielded = true }

    assert_not yielded, "Block should not have been called"
  end

  test "if_has_role yields when role exists" do
    @current_user = DummyActor.new(roles: { [ "admin", nil ] => true })

    assert_equal "ok", if_has_role("admin") { "ok" }
  end

  test "if_has_role does not yield when role is missing" do
    @current_user = DummyActor.new(roles: { [ "admin", nil ] => false })
    yielded = false
    if_has_role("admin") { yielded = true }

    assert_not yielded, "Block should not have been called"
  end
end
