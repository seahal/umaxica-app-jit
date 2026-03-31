# typed: false
# frozen_string_literal: true

require "singleton"

class Unauthenticated
  include Singleton

  def id
    nil
  end

  def user?
    false
  end

  def customer?
    false
  end

  def staff?
    false
  end

  def unauthenticated?
    true
  end

  def authenticated?
    false
  end
end
