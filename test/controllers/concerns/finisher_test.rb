# typed: false
# frozen_string_literal: true

require "test_helper"

# rubocop:disable Minitest/NoTestCases
class FinisherTest < ActiveSupport::TestCase
  class DummyController < ApplicationController
    include ::Finisher
  end
end
# rubocop:enable Minitest/NoTestCases
