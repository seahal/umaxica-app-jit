# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class ApplicationConsumerTest < ActiveSupport::TestCase
  def setup
    @consumer = ApplicationConsumer.new
  end

  test "#decrypt calls ActiveRecord::Encryption.encryptor.decrypt" do
    encrypted_data = "some-encrypted-data"
    decrypted_data = "some-decrypted-data"

    encryptor_mock = Minitest::Mock.new
    encryptor_mock.expect(:decrypt, decrypted_data, [ encrypted_data ])

    ActiveRecord::Encryption.stub(:encryptor, encryptor_mock) do
      result = @consumer.send(:decrypt, encrypted_data)

      assert_equal decrypted_data, result
    end

    encryptor_mock.verify
  end
end
