# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = "jit-foundation"
  spec.version     = "0.1.0"
  spec.authors     = ["seahal"]
  spec.summary     = "Jit Foundation Engine - Regional operations, contacts, and staff management"

  spec.required_ruby_version = ">= 3.4.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile"]
  end

  spec.add_dependency "rails", ">= 8.1"
end
