require "test_helper"

class Apex::Org::CustomersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_org_customers_url
    assert_response :success
  end

  test "should get new" do
    get new_apex_org_customer_url
    assert_response :success
  end

  test "should create customer" do
    assert_difference("Customer.count", 1) do
      post apex_org_customers_url, params: { customer: { name: "Test Customer" } }
    end
    assert_redirected_to apex_org_customer_url(Customer.last)
  end

  test "should show customer" do
    customer = customers(:one)
    get apex_org_customer_url(customer)
    assert_response :success
  end

  test "should get edit" do
    customer = customers(:one)
    get edit_apex_org_customer_url(customer)
    assert_response :success
  end

  test "should update customer" do
    customer = customers(:one)
    patch apex_org_customer_url(customer), params: { customer: { name: "Updated Name" } }
    assert_redirected_to apex_org_customer_url(customer)
  end

  test "should destroy customer" do
    customer = customers(:one)
    assert_difference("Customer.count", -1) do
      delete apex_org_customer_url(customer)
    end
    assert_redirected_to apex_org_customers_url
  end
end
