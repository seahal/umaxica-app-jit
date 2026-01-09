# frozen_string_literal: true

require "test_helper"
require_dependency Rails.root.join("app/models/concerns/recovery.rb").to_s

class RecoveryTest < ActiveSupport::TestCase
  test "can be included as a concern" do
    klass = Class.new { include Recovery }
    assert_includes klass.included_modules, Recovery
  end

  test "recovery_enabled? returns false by default" do
    klass = Class.new { include Recovery }
    instance = klass.new
    assert_not instance.recovery_enabled?
  end

  test "needs_recovery_setup? returns true by default" do
    klass = Class.new { include Recovery }
    instance = klass.new
    assert_predicate instance, :needs_recovery_setup?
  end
end
