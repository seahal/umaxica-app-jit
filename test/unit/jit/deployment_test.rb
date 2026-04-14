# typed: false
# frozen_string_literal: true

require "test_helper"

class JitDeploymentTest < ActiveSupport::TestCase
  def setup
    @original_mode = ENV["DEPLOY_MODE"]
  end

  def teardown
    if @original_mode.nil?
      ENV.delete("DEPLOY_MODE")
    else
      ENV["DEPLOY_MODE"] = @original_mode
    end
  end

  test "mode defaults to development" do
    ENV.delete("DEPLOY_MODE")

    assert_equal "development", Jit::Deployment.mode
  end

  test "mode returns value from DEPLOY_MODE" do
    ENV["DEPLOY_MODE"] = "signature"

    assert_equal "signature", Jit::Deployment.mode
  end

  test "signature? returns true for signature mode" do
    ENV["DEPLOY_MODE"] = "signature"

    assert_predicate Jit::Deployment, :signature?
  end

  test "signature? returns true for development mode" do
    ENV["DEPLOY_MODE"] = "development"

    assert_predicate Jit::Deployment, :signature?
  end

  test "signature? returns false for station mode" do
    ENV["DEPLOY_MODE"] = "station"

    assert_not Jit::Deployment.signature?
  end

  test "world? returns true for world mode" do
    ENV["DEPLOY_MODE"] = "world"

    assert_predicate Jit::Deployment, :world?
  end

  test "world? returns true for development mode" do
    ENV["DEPLOY_MODE"] = "development"

    assert_predicate Jit::Deployment, :world?
  end

  test "world? returns false for station mode" do
    ENV["DEPLOY_MODE"] = "station"

    assert_not Jit::Deployment.world?
  end

  test "station? returns true for station mode" do
    ENV["DEPLOY_MODE"] = "station"

    assert_predicate Jit::Deployment, :station?
  end

  test "station? returns true for development mode" do
    ENV["DEPLOY_MODE"] = "development"

    assert_predicate Jit::Deployment, :station?
  end

  test "station? returns false for signature mode" do
    ENV["DEPLOY_MODE"] = "signature"

    assert_not Jit::Deployment.station?
  end

  test "press? returns true for press mode" do
    ENV["DEPLOY_MODE"] = "press"

    assert_predicate Jit::Deployment, :press?
  end

  test "press? returns true for development mode" do
    ENV["DEPLOY_MODE"] = "development"

    assert_predicate Jit::Deployment, :press?
  end

  test "press? returns false for signature mode" do
    ENV["DEPLOY_MODE"] = "signature"

    assert_not Jit::Deployment.press?
  end

  test "global? combines signature and world modes" do
    ENV["DEPLOY_MODE"] = "signature"

    assert_predicate Jit::Deployment, :global?

    ENV["DEPLOY_MODE"] = "world"

    assert_predicate Jit::Deployment, :global?
  end

  test "local? combines station and press modes" do
    ENV["DEPLOY_MODE"] = "station"

    assert_predicate Jit::Deployment, :local?

    ENV["DEPLOY_MODE"] = "press"

    assert_predicate Jit::Deployment, :local?
  end
end
