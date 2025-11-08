# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class ApplicationConsumerTest < ActiveSupport::TestCase
  class PublicConsumer < ApplicationConsumer
    public :decrypt
  end

  test "#decrypt delegates to ActiveRecord encryptor" do
    consumer = PublicConsumer.allocate
    encryptor = Minitest::Mock.new
    encryptor.expect(:decrypt, "plain-text", [ "cipher-text" ])

    ActiveRecord::Encryption.stub :encryptor, encryptor do
      assert_equal "plain-text", consumer.decrypt("cipher-text")
    end

    encryptor.verify
  end
end
