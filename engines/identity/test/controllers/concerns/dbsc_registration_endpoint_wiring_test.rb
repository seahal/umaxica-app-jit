# typed: false
# frozen_string_literal: true

require "test_helper"

class DbscRegistrationEndpointWiringTest < ActiveSupport::TestCase
  test "sign dbsc controllers use shared registration endpoint concern" do
    assert_includes Jit::Identity::Sign::App::Edge::V0::Token::DbscController, Jit::Identity::Sign::DbscRegistrationEndpoint
    assert_includes Jit::Identity::Sign::Org::Edge::V0::Token::DbscController, Jit::Identity::Sign::DbscRegistrationEndpoint
  end

  test "acme dbsc controllers use shared preference registration endpoint concern" do
    assert_includes Jit::Zenith::Acme::App::Edge::V0::DbscController, Preference::DbscRegistrationEndpoint
    assert_includes Jit::Zenith::Acme::Org::Edge::V0::DbscController, Preference::DbscRegistrationEndpoint
    assert_includes Jit::Zenith::Acme::Com::Edge::V0::DbscController, Preference::DbscRegistrationEndpoint
  end

  test "controllers do not redefine dbsc registration internals locally" do
    sign_controllers = [
      Jit::Identity::Sign::App::Edge::V0::Token::DbscController,
      Jit::Identity::Sign::Org::Edge::V0::Token::DbscController,
    ]
    acme_controllers = [
      Jit::Zenith::Acme::App::Edge::V0::DbscController,
      Jit::Zenith::Acme::Org::Edge::V0::DbscController,
      Jit::Zenith::Acme::Com::Edge::V0::DbscController,
    ]

    (sign_controllers + acme_controllers).each do |controller|
      assert_not_includes controller.instance_methods(false), :handle_registration
      assert_not_includes controller.instance_methods(false), :handle_bound_cookie_refresh
      assert_not_includes controller.instance_methods(false), :dbsc_cookie_attributes_string
    end
  end
end
