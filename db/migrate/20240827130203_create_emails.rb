# frozen_string_literal: true

# if production?
PARTITION_SIZE = 15

class CreateEmails < ActiveRecord::Migration[7.2]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # I want to table emails as uniqueness of email address.
    execute <<-SQL
      CREATE TABLE emails(
                    address varchar(256) PRIMARY KEY,
                    type varchar not null,
                    created_at timestamp(6) not null,
                    updated_at timestamp(6) not null
                ) PARTITION BY LIST (address);
    SQL
  end

  # [*'0'..'9', *'a'..'z', '!', '#', '$', '%', '&', '\'', '*', '+', '-', '/', '=', '?', '^', '_', '`', '{', '|', '}', '~', '"'].each_with_index do |p, i|
  #   execute <<-SQL
  #     CREATE TABLE emails_p#{ i } PARTITION OF emails FOR VALUES WITH (MODULUS #{PARTITION_SIZE + 1}, REMAINDER #{i});
  #     CREATE UNIQUE INDEX emails_address_index_p#{ format('%02x', i) } ON emails_p#{ format('%02x', i) } (address);
  #   SQL
  # end

  def down
    execute <<-SQL
        DROP TABLE emails;
    SQL

    disabl_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
