# typed: false
# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../config/environment"

class DockerfileTest < Minitest::Test
  def test_jemalloc_is_enabled_in_production_and_development_images
    dockerfile = Rails.root.join("Dockerfile").read

    assert_equal 2, dockerfile.scan("libjemalloc2").size
    assert_equal 2, dockerfile.scan("LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2").size
  end
end
