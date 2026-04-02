# typed: false
# frozen_string_literal: true

<<<<<<<< HEAD:app/lib/core/surface.rb
module Core
========
# Main::Surface delegates to Core::Surface for backward compatibility
module Main
>>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.):app/lib/main/surface.rb
  module Surface
    ENV_KEY = Core::Surface::ENV_KEY
    DEFAULT = Core::Surface::DEFAULT
    SURFACES = Core::Surface::SURFACES

    def self.detect(request)
      Core::Surface.detect(request)
    end

    def self.current(request)
      Core::Surface.current(request)
    end

    def self.matches?(request, surface)
      Core::Surface.matches?(request, surface)
    end
<<<<<<<< HEAD:app/lib/core/surface.rb

    def normalized_host(value)
      Core::HostNormalization.normalize(value)
    end
    private_class_method :normalized_host

    def extract_host(request)
      return request.host if request.respond_to?(:host)

      request.to_s
    end
    private_class_method :extract_host
========
>>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.):app/lib/main/surface.rb
  end
end
