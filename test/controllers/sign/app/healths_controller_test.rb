<<<<<<<< HEAD:test/controllers/sign/org/healths_controller_test.rb
========
# typed: false
>>>>>>>> develop:test/controllers/sign/app/healths_controller_test.rb
# frozen_string_literal: true

require "test_helper"

<<<<<<<< HEAD:test/controllers/sign/org/healths_controller_test.rb
class Sign::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "GET /health returns OK response" do
    get sign_org_health_url(ri: "jp")
========
class Sign::App::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "GET /health returns OK response" do
    get sign_app_health_url(ri: "jp")
>>>>>>>> develop:test/controllers/sign/app/healths_controller_test.rb

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK html response" do
<<<<<<<< HEAD:test/controllers/sign/org/healths_controller_test.rb
    get sign_org_health_url(format: :html, ri: "jp")
========
    get sign_app_health_url(format: :html, ri: "jp")
>>>>>>>> develop:test/controllers/sign/app/healths_controller_test.rb

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK json response" do
<<<<<<<< HEAD:test/controllers/sign/org/healths_controller_test.rb
    get sign_org_health_url(format: :json, ri: "jp")
========
    get sign_app_health_url(format: :json, ri: "jp")
>>>>>>>> develop:test/controllers/sign/app/healths_controller_test.rb

    assert_response :success
    assert_includes response.body, "OK"
  end
end
