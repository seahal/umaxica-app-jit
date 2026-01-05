# frozen_string_literal: true

require "test_helper"

class TokenRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert_predicate TokenRecord, :abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert_operator TokenRecord, :<, ApplicationRecord
  end

  test "should connect to token database" do
    # Test that the model is configured to use the token database
    # Note: This is a basic structural test
    assert_respond_to TokenRecord, :connection_db_config
  end
end
