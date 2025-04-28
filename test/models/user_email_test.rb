# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id         :binary           default(""), not null
#  address    :string(512)      not null, primary key
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UserEmailTest < ActiveSupport::TestCase
  # Tests of user_email is described at email_test.rb
end
