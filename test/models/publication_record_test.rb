# typed: false
# frozen_string_literal: true

require "test_helper"

class PublicationRecordTest < ActiveSupport::TestCase
  test "is abstract" do
    assert_predicate PublicationRecord, :abstract_class?
  end

  test "connects to publication database" do
    config = PublicationRecord.connection_db_config

    assert_equal "publication", config.name
    assert_match(/^test_publication_db(_\d+)?$/, config.database)
    assert_match(/^test_publication_db(_\d+)?$/, PublicationRecord.connection.select_value("SELECT current_database()"))
  end
end
