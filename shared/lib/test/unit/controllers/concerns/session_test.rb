# typed: false
# frozen_string_literal: true

require "test_helper"

class SessionConcernUnitTest < ActiveSupport::TestCase
  include Session

  setup do
    Current.reset
    @session = Hash.new
  end

  # Stub session for testing
  def session
    @session
  end

  # Stub flash
  def flash
    @flash ||= FlashStub.new
  end

  class FlashStub
    attr_reader :discarded

    def initialize
      @data = {}
      @discarded = false
    end

    delegate :[], to: :@data

    delegate :[]=, to: :@data

    delegate :any?, to: :@data

    def discard
      @discarded = true
    end
  end

  test "validate_flash_boundary does nothing when no stored boundary" do
    Current.realm = :sign
    Current.surface = :app
    validate_flash_boundary

    assert_not flash.discarded
  end

  test "validate_flash_boundary does nothing when boundaries match" do
    Current.realm = :sign
    Current.surface = :app
    @session[:_flash_boundary] = "sign:app"
    validate_flash_boundary

    assert_not flash.discarded
  end

  test "validate_flash_boundary discards flash on mismatch" do
    Current.realm = :core
    Current.surface = :app
    @session[:_flash_boundary] = "acme:org"
    flash[:alert] = "test" # rubocop:disable Rails/I18nLocaleTexts
    validate_flash_boundary

    assert flash.discarded
    assert_nil @session[:_flash_boundary]
  end

  test "validate_flash_boundary allows sign->core transition" do
    Current.realm = :core
    Current.surface = :app
    @session[:_flash_boundary] = "sign:app"
    validate_flash_boundary

    assert_not flash.discarded
  end

  test "record_flash_boundary stores current boundary" do
    Current.realm = :sign
    Current.surface = :app
    record_flash_boundary

    assert_equal "sign:app", @session[:_flash_boundary]
  end

  test "reset_flash discards flash and clears boundary" do
    @session[:_flash_boundary] = "sign:app"
    flash[:alert] = "test" # rubocop:disable Rails/I18nLocaleTexts
    reset_flash

    assert flash.discarded
    assert_nil @session[:_flash_boundary]
  end

  teardown do
    Current.reset
  end
end
