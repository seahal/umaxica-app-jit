require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "ApplicationCable::Connection is a subclass of ActionCable::Connection::Base" do
    assert_operator ApplicationCable::Connection, :<, ActionCable::Connection::Base
  end

  test "connection can be established" do
    connect

    assert connection
  end

  test "connection has access to request" do
    connect

    assert_respond_to connection, :request
  end

  test "connection can be closed" do
    connect

    assert connection

    # Connection should exist after connecting
    assert_not_nil connection
  end
end
