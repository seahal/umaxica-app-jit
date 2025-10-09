# frozen_string_literal: true

require "test_helper"

class UserSessionTest < ActiveSupport::TestCase
  test "inherits from TokensRecord" do
    assert UserSession < TokensRecord
  end

  test "belongs to user" do
    association = UserSession.reflect_on_association(:user)
    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end
end
