# frozen_string_literal: true

require "test_helper"

class CommonControllerTest < ActionDispatch::IntegrationTest
  test "function test" do
    assert true
  end

#   test "should get new" do
#     get new_term_url
#     assert_response :success
#   end
#
#   test "should create term" do
#     assert_difference("Term.count") do
#       post terms_url, params: { term: { body: @term.body, staff_id: @term.staff_id, title: @term.title } }
#     end
#
#     assert_redirected_to term_url(Term.last)
#   end
#
#   test "should show term" do
#     get term_url(@term)
#     assert_response :success
#   end
#
#   test "should get edit" do
#     get edit_term_url(@term)
#     assert_response :success
#   end
#
#   test "should update term" do
#     patch term_url(@term), params: { term: { body: @term.body, staff_id: @term.staff_id, title: @term.title } }
#     assert_redirected_to term_url(@term)
#   end
#
#   test "should destroy term" do
#     assert_difference("Term.count", -1) do
#       delete term_url(@term)
#     end
#
#     assert_redirected_to terms_url
#   end
end
