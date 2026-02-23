# typed: false
# frozen_string_literal: true

# Fix for old gems that still use Fixnum or Bignum in Ruby 3+
unless defined?(Fixnum)
  Fixnum = Integer
end

unless defined?(Bignum)
  Bignum = Integer
end

# Fix for old gems that use File.exists? instead of File.exist?
unless File.respond_to?(:exists?)
  def File.exists?(path)
    exist?(path)
  end
end

# String#drop is not a standard Ruby method but is used in this codebase.
# Adding it here to ensure compatibility and solve NoMethodError fundamentally.
class String
  def drop(n)
    self[n..] || ""
  end
end
