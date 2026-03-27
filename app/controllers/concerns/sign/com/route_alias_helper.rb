# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module RouteAliasHelper
      {
        "sign_app_" => "sign_com_",
        "apex_app_" => "apex_com_",
      }.each do |source_prefix, target_prefix|
        Rails.application.routes.url_helpers.public_instance_methods.grep(/^#{source_prefix}/).each do |helper_name|
          target_helper_name = helper_name.to_s.sub(source_prefix, target_prefix)
          next unless Rails.application.routes.url_helpers.public_instance_methods.include?(target_helper_name.to_sym)

          define_method(helper_name) do |*args, **kwargs, &block|
            public_send(target_helper_name, *args, **kwargs, &block)
          end
        end
      end
    end
  end
end
