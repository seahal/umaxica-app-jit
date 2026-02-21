# frozen_string_literal: true

class ApplicationService
  # Provides a convenient interface.
  # Can be invoked as `Service.call(*args, **kwargs)`.
  #
  # Subclasses must implement the `#call` instance method.
  def self.call(...)
    new(...).call
  end

  # Default initialization method. Override as needed in subclasses.
  def initialize(*)
  end

  def call
    raise NotImplementedError, "#{self.class} #call is not implemented"
  end
end
