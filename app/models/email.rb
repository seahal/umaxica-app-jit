# frozen_string_literal: true

# MEMO: SHA3::Digest::SHA3_256.new(ENV['SINGLETON_DEFAULT_SALT'] + 'one@example.com').digest

# == Schema Information
#
# Table name: emails
#
#  id             :binary           default(""), not null
#  address        :string(512)      not null, primary key
#  entryable_type :string           not null
#  type           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  entryable_id   :binary           not null
#
class Email < AccountsRecord
  self.primary_key = :address
  #
  # has_one :user, foreign_key: "id"
  # has_one :staff, foreign_key: "id"
end
