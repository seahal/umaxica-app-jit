# frozen_string_literal: true

# MEMO: SHA3::Digest::SHA3_256.new(ENV['SINGLETON_DEFAULT_SALT'] + 'one@example.com').digest

# == Schema Information
#
# Table name: emails
#
#  id             :binary           default(""), not null, primary key
#  address        :string(1024)     not null
#  emailable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  emailable_id   :binary           not null
#
class Email < AccountsRecord
end
