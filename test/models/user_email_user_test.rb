# frozen_string_literal: true

require "test_helper"

class UserEmailUserTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  test "email user relation" do
    ue = UserEmail.new(address: "one@example.com", confirm_policy: true)
    assert ue.valid?
    assert ue.save
  end
end
