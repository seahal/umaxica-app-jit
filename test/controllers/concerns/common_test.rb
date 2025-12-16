# frozen_string_literal: true

require "test_helper"

class CommonTest < ActiveSupport::TestCase
  class DummyClass
    include Common
  end

  setup do
    @dummy = DummyClass.new
  end

  test "gen_original_uuid returns a uuid" do
    uuid = @dummy.send(:gen_original_uuid)

    assert_match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, uuid)
  end

  test "localize_time converts to Tokyo time" do
    time = Time.utc(2023, 1, 1, 0, 0, 0)
    local_time = @dummy.send(:localize_time, time)

    assert_equal "Tokyo", local_time.time_zone.name
    assert_equal 9, local_time.hour # Tokyo is UTC+9
  end

  test "text_encryption encrypts text" do
    text = "secret"
    encrypted = @dummy.send(:text_encryption, text)

    assert_not_equal text, encrypted
    decrypted = ActiveRecord::Encryption.encryptor.decrypt(encrypted)

    assert_equal text, decrypted
  end
end
