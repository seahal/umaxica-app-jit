# typed: false
# frozen_string_literal: true

require "test_helper"

class SettingRecordTest < ActiveSupport::TestCase
  test "connects to setting database" do
    config = SettingRecord.connection_db_config

    assert_equal "setting", config.name
    assert_match(/^test_setting_db(_\d+)?$/, config.database)
    assert_match(/^test_setting_db(_\d+)?$/, SettingRecord.connection.select_value("SELECT current_database()"))
  end
end
