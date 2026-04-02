# typed: false
# frozen_string_literal: true

<<<<<<<< HEAD:app/lib/core/host_normalization.rb
require "uri"

module Core
========
# Main::HostNormalization delegates to Core::HostNormalization for backward compatibility
module Main
>>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.):app/lib/main/host_normalization.rb
  module HostNormalization
    def self.normalize(value)
      Core::HostNormalization.normalize(value)
    end
  end
end
