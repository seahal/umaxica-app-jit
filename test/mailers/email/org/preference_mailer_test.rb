# frozen_string_literal: true

require "test_helper"

module Email::Org
  class PreferenceMailerTest < ActionMailer::TestCase
    test "PreferenceMailer has update_request method" do
      assert_respond_to PreferenceMailer, :update_request
    end

    test "PreferenceMailer inherits from ApplicationMailer" do
      assert_kind_of Class, PreferenceMailer
      assert_operator PreferenceMailer, :<, ApplicationMailer
    end
  end
end
