
class CookieMock < Hash
  def encrypted
    self
  end

  def []=(key, value)
    # If value is a hash with :value key (cookie options), store just the value
    super(key, value.is_a?(Hash) && value.key?(:value) ? value[:value] : value)
  end

  def delete(key, options = {})
    super(key)
  end
end

cookies = CookieMock.new
cookies[:access_user_token] = { value: "token", httponly: true }
puts "After set: #{cookies[:access_user_token].inspect}"

cookies.delete :access_user_token
puts "After delete: #{cookies[:access_user_token].inspect}"
