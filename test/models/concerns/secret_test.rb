# frozen_string_literal: true

require "test_helper"

class SecretTest < ActiveSupport::TestCase
  class SecretStatus
    def self.find(id)
      new(id)
    end

    attr_reader :id

    def initialize(id)
      @id = id
    end
  end

  class DummySecret
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include ActiveModel::SecurePassword

    attribute :id, :string
    attribute :name, :string
    attribute :uses_remaining, :integer
    attribute :expires_at, :datetime
    attribute :last_used_at, :datetime
    attribute :secret_status_id, :string
    attribute :password_digest, :string

    # We need to include Secret LAST so it can override/use methods
    include Secret

    def self.identity_secret_status_class
      SecretStatus
    end

    def self.identity_secret_status_id_column
      :secret_status_id
    end

    # Mock DB columns for write access
    def [](key)
      if key.to_s == "secret_status_id"
        attributes[key.to_s]
      else
        send(key)
      end
    end

    def []=(key, value)
      send("#{key}=", value)
    end

    # Mock ActiveRecord methods
    def save!
      true
    end

    def reload
      self
    end

    def with_lock
      yield
    end

    # Mock has_secure_password behavior without full ActiveModel::SecurePassword overhead if needed,
    # but we included it.
  end

  test "defines constants" do
    assert_defined_constant Secret::SECRET_PASSWORD_LENGTH
  end

  test "issue! creates a new record with generated secret" do
    record, raw_secret = DummySecret.issue!(name: "test")

    assert_kind_of DummySecret, record
    assert_equal "test", record.name
    assert_equal 32, raw_secret.length
    assert_equal DummySecret.status_id_for(:active), record[:secret_status_id]
  end

  test "verify_and_consume! decrements uses" do
    record, raw_secret = DummySecret.issue!(name: "test", uses: 5)

    assert record.verify_and_consume!(raw_secret)
    assert_equal 4, record.uses_remaining
  end

  test "verify_and_consume! expires when uses exhausted" do
    record, raw_secret = DummySecret.issue!(name: "test", uses: 1)

    assert record.verify_and_consume!(raw_secret)
    assert_equal 0, record.uses_remaining
    assert_equal DummySecret.status_id_for(:used), record[:secret_status_id]
  end

  test "expire_if_needed! expires when time passed" do
    record, _ = DummySecret.issue!(name: "test", expires_at: 1.hour.ago)

    assert record.expire_if_needed!
    assert_equal DummySecret.status_id_for(:expired), record[:secret_status_id]
  end

  private

  def assert_defined_constant(constant)
    assert defined?(constant)
  end
end
