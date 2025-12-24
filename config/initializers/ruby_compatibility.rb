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
