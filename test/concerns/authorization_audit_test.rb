# frozen_string_literal: true

require "test_helper"

class AuthorizationAuditTest < ActiveSupport::TestCase
  class DummyPolicy; end

  class DummyAudit
    def self.rescue_from(*)
    end

    include AuthorizationAudit

    attr_accessor :current_user, :current_staff, :request, :action_name, :controller_name

    def initialize(current_user: nil, current_staff: nil)
      @current_user = current_user
      @current_staff = current_staff
      @action_name = "show"
      @controller_name = "widgets"
      @request = OpenStruct.new(remote_ip: "127.0.0.1", user_agent: "TestAgent")
    end
  end

  test "current_user_or_staff prefers current_user" do
    user = users(:one)
    staff = staffs(:one)
    audit = DummyAudit.new(current_user: user, current_staff: staff)

    assert_equal user, audit.send(:current_user_or_staff)
  end

  test "current_user_or_staff falls back to current_staff" do
    staff = staffs(:one)
    audit = DummyAudit.new(current_user: nil, current_staff: staff)

    assert_equal staff, audit.send(:current_user_or_staff)
  end

  test "log_authorization_failure notifies once" do
    user = users(:one)
    exception = build_exception(record: users(:two))
    audit = DummyAudit.new(current_user: user)

    result = capture_log_data(audit, exception)

    assert_equal [ "authorization.failure" ], result[:events].map(&:first)
  end

  test "log_authorization_failure routes to user audit" do
    user = users(:one)
    exception = build_exception(record: users(:two))
    audit = DummyAudit.new(current_user: user)

    result = capture_log_data(audit, exception)

    assert result[:user_called]
    assert_not result[:staff_called]
  end

  test "log_authorization_failure routes to staff audit" do
    staff = staffs(:one)
    exception = build_exception(record: staff)
    audit = DummyAudit.new(current_staff: staff)

    result = capture_log_data(audit, exception)

    assert result[:staff_called]
    assert_not result[:user_called]
  end

  test "log_authorization_failure includes actor metadata" do
    user = users(:one)
    exception = build_exception(record: users(:two))
    audit = DummyAudit.new(current_user: user)

    result = capture_log_data(audit, exception)

    assert_equal "User", result[:log_data][:actor_type]
    assert_equal user.id, result[:log_data][:actor_id]
  end

  test "log_authorization_failure includes policy metadata" do
    user = users(:one)
    exception = build_exception(record: users(:two))
    audit = DummyAudit.new(current_user: user)

    result = capture_log_data(audit, exception)

    assert_equal "AuthorizationAuditTest::DummyPolicy", result[:log_data][:policy]
    assert_equal :show?, result[:log_data][:query]
  end

  test "log_authorization_failure includes record metadata" do
    user = users(:one)
    record = users(:two)
    exception = build_exception(record: record)
    audit = DummyAudit.new(current_user: user)

    result = capture_log_data(audit, exception)

    assert_equal "User", result[:log_data][:record_type]
    assert_equal record.id, result[:log_data][:record_id]
  end

  test "log_authorization_failure includes request metadata" do
    user = users(:one)
    exception = build_exception(record: users(:two))
    audit = DummyAudit.new(current_user: user)

    result = capture_log_data(audit, exception)

    assert_equal "127.0.0.1", result[:log_data][:ip_address]
    assert_equal "TestAgent", result[:log_data][:user_agent]
  end

  test "log_authorization_failure includes timestamp" do
    user = users(:one)
    exception = build_exception(record: users(:two))
    audit = DummyAudit.new(current_user: user)

    result = capture_log_data(audit, exception)

    assert_kind_of Time, result[:log_data][:timestamp]
  end

  test "log_authorization_failure skips when no actor" do
    audit = DummyAudit.new
    exception = build_exception(record: users(:one))

    result = capture_log_data(audit, exception)

    assert_empty result[:events]
    assert_not result[:user_called]
  end

  private

  def build_exception(record:)
    OpenStruct.new(policy: DummyPolicy.new, query: :show?, record: record)
  end

  def capture_log_data(audit, exception)
    result = { events: [], user_called: false, staff_called: false, log_data: nil }

    audit.define_singleton_method(:create_user_authorization_audit) do |_actor, log_data|
      result[:user_called] = true
      result[:log_data] = log_data
    end
    audit.define_singleton_method(:create_staff_authorization_audit) do |_actor, log_data|
      result[:staff_called] = true
      result[:log_data] = log_data
    end

    notifier = Struct.new(:events) do
      def notify(name, payload)
        events << [ name, payload ]
      end
    end

    Rails.stub(:event, notifier.new(result[:events])) do
      audit.send(:log_authorization_failure, exception)
    end

    result
  end
end
