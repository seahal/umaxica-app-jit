# frozen_string_literal: true

class SeedTokenKinds < ActiveRecord::Migration[8.2]
  TOKEN_KINDS = %w(BROWSER_WEB CLIENT_IOS CLIENT_ANDROID).freeze

  def up
    safety_assured do
      TOKEN_KINDS.each do |kind_id|
        execute(<<~SQL.squish)
          INSERT INTO user_token_kinds (id, created_at, updated_at)
          VALUES (#{connection.quote(kind_id)}, NOW(), NOW())
          ON CONFLICT (id) DO NOTHING
        SQL
        execute(<<~SQL.squish)
          INSERT INTO staff_token_kinds (id, created_at, updated_at)
          VALUES (#{connection.quote(kind_id)}, NOW(), NOW())
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end

  def down
    safety_assured do
      execute(<<~SQL.squish)
        DELETE FROM user_token_kinds WHERE id IN (#{TOKEN_KINDS.map { |k| connection.quote(k) }.join(", ")})
      SQL
      execute(<<~SQL.squish)
        DELETE FROM staff_token_kinds WHERE id IN (#{TOKEN_KINDS.map { |k| connection.quote(k) }.join(", ")})
      SQL
    end
  end
end
