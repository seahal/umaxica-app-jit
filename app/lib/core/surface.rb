# frozen_string_literal: true

module Core
  module Surface
    ENV_KEY = "jit.surface"
    DEFAULT = :com
    SURFACES = %i(app com org).freeze

    module_function

    def detect(request)
      host = normalized_host(extract_host(request))
      return DEFAULT if host.blank?

      labels = host.split(".")
      labels.each do |label|
        surface = label.to_sym
        return surface if SURFACES.include?(surface)
      end

      DEFAULT
    end

    def current(request)
      env = request.respond_to?(:env) ? request.env : nil
      value = env&.[](ENV_KEY)
      return value.to_sym if value.present? && SURFACES.include?(value.to_sym)

      detected = detect(request)
      env[ENV_KEY] = detected if env
      detected
    end

    def matches?(request, surface)
      current(request) == surface.to_sym
    end

    def normalized_host(value)
      return nil if value.blank?

      value.to_s.downcase.delete_suffix(".").split(":").first
    end
    private_class_method :normalized_host

    def extract_host(request)
      return request.host if request.respond_to?(:host)

      request.to_s
    end
    private_class_method :extract_host
  end
end
