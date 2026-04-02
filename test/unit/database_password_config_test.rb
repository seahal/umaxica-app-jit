# typed: false
# frozen_string_literal: true

require "test_helper"

class DatabasePasswordConfigTest < ActiveSupport::TestCase
  test "database password prefers POSTGRESQL_PASSWORD over credentials" do
    database_yml = Rails.root.join("config/database.yml").read

    assert_match(
      /password: <%= ENV\["POSTGRESQL_PASSWORD"\]\.presence \|\| Rails\.application\.credentials\.dig\(:DATABASE, :PASSWORD\) %>/,
      database_yml,
    )
  end
end
