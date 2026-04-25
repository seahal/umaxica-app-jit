# typed: false
# frozen_string_literal: true

require "test_helper"

class ApplicationServiceTest < ActiveSupport::TestCase
  class TestService < ApplicationService
    attr_reader :value

    def initialize(value:)
      super
      @value = value
    end

    def call
      @value * 2
    end
  end

  class FailingService < ApplicationService
    def call
      raise NotImplementedError, "test error"
    end
  end

  test ".call invokes new and call" do
    result = TestService.call(value: 21)

    assert_equal 42, result
  end

  test "#call raises NotImplementedError when not overridden" do
    assert_raises(NotImplementedError) do
      ApplicationService.new.call
    end
  end
end
