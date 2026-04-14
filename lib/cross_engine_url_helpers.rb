# typed: false
# frozen_string_literal: true

# Provides cross-engine route helpers for all controllers and views.
#
# Rails engine url_helpers cannot be directly included together because each
# module defines its own `_routes` method. The last included module wins and
# earlier engines' helpers break. This module works around that limitation by
# maintaining a separate proxy instance per engine and dispatching helper calls
# to the correct proxy based on the route name prefix.
#
# For `_url` helpers, the host is automatically injected from ENV variables
# when not explicitly provided.
#
# Usage in controllers and views (after initializer loads):
#
#   sign_app_root_path                        # => "/"
#   new_sign_app_in_url(ri: "jp")             # => "http://sign.app.localhost/in/new?ri=jp"
#   apex_app_root_url                         # => "http://app.localhost/"
#   main_org_health_url                       # => "http://www.org.localhost/health"
#   docs_com_root_url                         # => "http://docs.com.localhost/"
#   sign_app_root_url(host: "custom.example") # => "http://custom.example/"
#
module CrossEngineUrlHelpers
  ENGINES = {
    signature: Jit::Signature::Engine,
    world: Jit::World::Engine,
    station: Jit::Station::Engine,
    press: Jit::Press::Engine,
  }.freeze

  # Maps route name patterns to ENV keys for automatic host injection.
  # Patterns are anchor-free to match new_*, edit_*, and bare prefixes.
  HOST_MAP = {
    /sign_app/ => "SIGN_SERVICE_URL",
    /sign_org/ => "SIGN_STAFF_URL",
    /sign_com/ => "SIGN_CORPORATE_URL",
    /apex_app/ => "APEX_SERVICE_URL",
    /apex_org/ => "APEX_STAFF_URL",
    /apex_com/ => "APEX_CORPORATE_URL",
    /main_app/ => "MAIN_SERVICE_URL",
    /main_org/ => "MAIN_STAFF_URL",
    /main_com/ => "MAIN_CORPORATE_URL",
    /docs_app/ => "DOCS_SERVICE_URL",
    /docs_org/ => "DOCS_STAFF_URL",
    /docs_com/ => "DOCS_CORPORATE_URL",
  }.freeze

  # Maps route name prefix to engine key.
  ROUTE_PREFIX_TO_ENGINE = {
    "sign_" => :signature,
    "apex_" => :world,
    "main_" => :station,
    "docs_" => :press,
  }.freeze

  private

  def cross_engine_proxies
    @cross_engine_proxies ||=
      ENGINES.transform_values do |engine|
        proxy_class =
          Class.new do
            include engine.routes.url_helpers

            define_method(:default_url_options) do
              {}
            end
          end

        proxy_class.new
      end
  end

  def find_engine_for_route(name)
    bare = name.to_s.delete_prefix("new_").delete_prefix("edit_")
    ROUTE_PREFIX_TO_ENGINE.each do |prefix, engine_key|
      return engine_key if bare.start_with?(prefix)
    end
    nil
  end

  def inject_cross_engine_host(name, kwargs)
    return if kwargs.key?(:host)

    name_str = name.to_s
    HOST_MAP.each do |pattern, env_key|
      next unless name_str.match?(pattern)

      kwargs[:host] = ENV[env_key]
      break
    end
  end

  def method_missing(name, *, **kwargs, &)
    engine_key = find_engine_for_route(name)
    if engine_key
      proxy = cross_engine_proxies[engine_key]
      if proxy.respond_to?(name)
        inject_cross_engine_host(name, kwargs) if name.end_with?("_url")
        return proxy.public_send(name, *, **kwargs, &)
      end
    end
    super
  end

  def respond_to_missing?(name, include_private = false)
    engine_key = find_engine_for_route(name)
    return true if engine_key && cross_engine_proxies[engine_key]&.respond_to?(name)

    super
  end
end
