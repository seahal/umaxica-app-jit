# frozen_string_literal: true

module Core
  class SurfaceMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      env[Core::Surface::ENV_KEY] = Core::Surface.detect(request)
      @app.call(env)
    end
  end
end
