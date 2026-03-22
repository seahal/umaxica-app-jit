# typed: false
# frozen_string_literal: true

require "test_helper"

class FinisherTest < ActiveSupport::TestCase
  class DummyController < ApplicationController
    include ::Finisher
  end
end
