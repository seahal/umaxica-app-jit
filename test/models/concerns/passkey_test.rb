# frozen_string_literal: true

require "test_helper"
require_dependency Rails.root.join("app/models/concerns/passkey.rb").to_s

class PasskeyTest < ActiveSupport::TestCase
  test "can be included as a concern" do
    klass = Class.new { include Passkey }
    assert_includes klass.included_modules, Passkey
  end

  test "passkey_enabled? returns false by default" do
    klass = Class.new { include Passkey }
    instance = klass.new
    assert_not instance.passkey_enabled?
  end

  test "can_register_passkey? returns true if staff_passkeys exists" do
    klass =
      Class.new do
        include Passkey

        def staff_passkeys
        end
      end
    assert_predicate klass.new, :can_register_passkey?
  end

  test "can_register_passkey? returns true if user_passkeys exists" do
    klass =
      Class.new do
        include Passkey

        def user_passkeys
        end
      end
    assert_predicate klass.new, :can_register_passkey?
  end

  test "can_register_passkey? returns false otherwise" do
    klass = Class.new { include Passkey }
    assert_not klass.new.can_register_passkey?
  end
end
