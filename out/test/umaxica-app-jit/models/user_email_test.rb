# == Schema Information
#
# Table name: user_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UserEmailTest < ActiveSupport::TestCase
  # ... some tests are written at emails_test.rb
end
