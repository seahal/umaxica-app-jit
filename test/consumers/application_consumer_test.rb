# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class ApplicationConsumerTest < ActiveSupport::TestCase
  def setup
    @consumer = ApplicationConsumer.new
  end
end
