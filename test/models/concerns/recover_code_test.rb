require "test_helper"

# Test class to include the RecoverCode concern
class DummyRecoverCodeModel
  include RecoverCode

  def initialize
    @confirm_policy = nil
    @confirm_using_mfa = nil
    @pass_code = nil
  end
end

class RecoverCodeTest < ActiveSupport::TestCase
  setup do
    @model = DummyRecoverCodeModel.new
  end

  test "concern can be included in a class" do
    assert_includes DummyRecoverCodeModel.included_modules, RecoverCode
  end

  test "concern adds confirm_policy accessor" do
    assert_respond_to @model, :confirm_policy
    assert_respond_to @model, :confirm_policy=
  end

  test "concern adds confirm_using_mfa accessor" do
    assert_respond_to @model, :confirm_using_mfa
    assert_respond_to @model, :confirm_using_mfa=
  end

  test "concern adds pass_code accessor" do
    assert_respond_to @model, :pass_code
    assert_respond_to @model, :pass_code=
  end

  test "confirm_policy can be set and retrieved" do
    @model.confirm_policy = "test_policy"

    assert_equal "test_policy", @model.confirm_policy
  end

  test "confirm_using_mfa can be set and retrieved" do
    @model.confirm_using_mfa = true

    assert @model.confirm_using_mfa
  end

  test "pass_code can be set and retrieved" do
    @model.pass_code = "123456"

    assert_equal "123456", @model.pass_code
  end

  test "accessors default to nil" do
    assert_nil @model.confirm_policy
    assert_nil @model.confirm_using_mfa
    assert_nil @model.pass_code
  end

  test "multiple instances maintain separate accessor values" do
    model1 = DummyRecoverCodeModel.new
    model2 = DummyRecoverCodeModel.new

    model1.pass_code = "111111"
    model2.pass_code = "222222"

    assert_equal "111111", model1.pass_code
    assert_equal "222222", model2.pass_code
  end

  test "concern extends ActiveSupport::Concern" do
    assert_kind_of Module, RecoverCode
  end
end
