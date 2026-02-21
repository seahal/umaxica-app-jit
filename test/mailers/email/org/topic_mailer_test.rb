# frozen_string_literal: true

require "ostruct"
require "test_helper"

module Email::Org
  class TopicMailerTest < ActionMailer::TestCase
    test "TopicMailer has notice method" do
      assert_respond_to TopicMailer, :notice
    end

    test "TopicMailer inherits from ApplicationMailer" do
      assert_kind_of Class, TopicMailer
      assert_operator TopicMailer, :<, ApplicationMailer
    end
  end
end
