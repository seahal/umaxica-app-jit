# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: passkeys
# Database name: principal
#
#  id            :uuid             not null, primary key
#  public_key    :text             not null
#  sign_count    :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  credential_id :string           not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_passkeys_on_credential_id  (credential_id) UNIQUE
#  index_passkeys_on_user_id        (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  test "passkey exists" do
    assert defined?(Passkey)
    assert_kind_of Class, Passkey
  end
end
