# typed: false
# frozen_string_literal: true

class AnyInstanceStubProxy
  def initialize(klass)
    @klass = klass
  end

  def stub(method_name, value = nil)
    method_sym = method_name.to_sym
    original_method = fetch_original_method(method_sym)
    had_original = !original_method.nil?

    @klass.define_method(method_sym) do |*args, **kwargs, &blk|
      if value.respond_to?(:call)
        value.call(*args, **kwargs, &blk)
      else
        value
      end
    end

    yield
  ensure
    if had_original
      @klass.define_method(method_sym, original_method)
    else
      @klass.remove_method(method_sym)
    end
  end

  private

  def fetch_original_method(method_sym)
    has_method =
      @klass.instance_methods.include?(method_sym) ||
      @klass.private_instance_methods.include?(method_sym) ||
      @klass.protected_instance_methods.include?(method_sym)
    return @klass.instance_method(method_sym) if has_method

    nil
  end
end

class Class
  def any_instance
    AnyInstanceStubProxy.new(self)
  end
end
