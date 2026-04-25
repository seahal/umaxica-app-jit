# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Com
        module RouteAliasHelper
          extend ActiveSupport::Concern

          included do
            # Eagerly load route helpers by including the module in a temporary class
            # This ensures all route helper methods are generated before we try to alias them
            temp_class = Class.new { include Rails.application.routes.url_helpers }
            temp_instance = temp_class.new
            temp_instance.define_singleton_method(:url_options) do
              { host: "localhost" }
            end

            # Trigger method generation by calling a route helper
            begin
              temp_instance.public_send(:sign_com_root_path) if temp_instance.respond_to?(:sign_com_root_path)
            rescue
              nil
            end

            {
              "sign_app_" => "sign_com_",
              "acme_app_" => "acme_com_",
            }.each do |source_prefix, target_prefix|
              temp_instance.methods.grep(/^#{source_prefix}/).each do |helper_name|
                target_helper_name = helper_name.to_s.sub(source_prefix, target_prefix)
                next unless temp_instance.respond_to?(target_helper_name)

                define_method(helper_name) do |*args, **kwargs, &block|
                  public_send(target_helper_name, *args, **kwargs, &block)
                end
              end
            end
          end
        end
      end
    end
  end
end
