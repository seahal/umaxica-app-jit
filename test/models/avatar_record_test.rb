# typed: false
# frozen_string_literal: true

require "test_helper"

class AvatarRecordTest < ActiveSupport::TestCase
  test "is abstract" do
    assert_predicate AvatarRecord, :abstract_class?
  end

  test "connects to avatar database" do
    config = AvatarRecord.connection_db_config

    assert_equal "avatar", config.name
    assert_match(/^test_avatar_db(_\d+)?$/, config.database)
    assert_match(/^test_avatar_db(_\d+)?$/, AvatarRecord.connection.select_value("SELECT current_database()"))
  end
end
