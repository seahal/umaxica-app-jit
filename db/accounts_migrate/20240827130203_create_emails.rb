# frozen_string_literal: true

# ToDo: Use table partitioning.
# ToDo: Use hash index


# # if production?
# PARTITION_SIZE = 15

class CreateEmails < ActiveRecord::Migration[7.2]
  def up
    # I want to table emails as uniqueness of email address.
    execute <<-SQL
        CREATE TABLE emails ( id bytea PRIMARY KEY NOT NULL default '',
                              address varchar (512) NOT NULL,
                              type varchar not null,
                              created_at timestamp(6) not null,
                              updated_at timestamp(6) not null );
    SQL
  end

  # [*'0'..'9', *'a'..'z', '!', '#', '$', '%', '&', '\'', '*', '+', '-', '/', '=', '?', '^', '_', '`', '{', '|', '}', '~', '"'].each_with_index do |p, i|
  #   execute <<-SQL
  #     CREATE TABLE emails_p#{ i } PARTITION OF emails FOR VALUES WITH (MODULUS #{PARTITION_SIZE + 1}, REMAINDER #{i});
  #     CREATE UNIQUE INDEX emails_address_index_p#{ format('%02x', i) } ON emails_p#{ format('%02x', i) } (address);
  #   SQL
  # end
  #       CREATE TABLE emails(
  #                     address varchar(256) PRIMARY KEY,
  #                     type varchar not null,
  #                     created_at timestamp(6) not null,
  #                     updated_at timestamp(6) not null
  #                 ) PARTITION BY LIST (address);

  def down
    execute <<-SQL
          DROP TABLE emails;
    SQL
  end
end
