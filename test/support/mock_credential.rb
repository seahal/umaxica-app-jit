# typed: false
# frozen_string_literal: true

class MockCredential < Struct.new(:id, :sign_count)
  def verify(_challenge, **)
    true
  end
end
