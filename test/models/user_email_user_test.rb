# frozen_string_literal: true

require "test_helper"

class UserEmailUserTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  test "email user relation" do
    ue = UserEmail.create(id:'0c0x', address: "one@example.com")
    assert ue.valid?
  end
end
