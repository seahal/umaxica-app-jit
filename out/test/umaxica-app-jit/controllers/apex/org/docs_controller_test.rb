require "test_helper"

class Apex::Org::DocsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_org_docs_url
    assert_response :success
  end

  test "should get new" do
    get new_apex_org_doc_url
    assert_response :success
  end

  test "should create doc" do
    assert_difference("Doc.count", 1) do
      post apex_org_docs_url, params: { doc: { title: "Test Doc" } }
    end
    assert_redirected_to apex_org_doc_url(Doc.last)
  end

  test "should show doc" do
    doc = docs(:one)
    get apex_org_doc_url(doc)
    assert_response :success
  end

  test "should get edit" do
    doc = docs(:one)
    get edit_apex_org_doc_url(doc)
    assert_response :success
  end

  test "should update doc" do
    doc = docs(:one)
    patch apex_org_doc_url(doc), params: { doc: { title: "Updated Title" } }
    assert_redirected_to apex_org_doc_url(doc)
  end

  test "should destroy doc" do
    doc = docs(:one)
    assert_difference("Doc.count", -1) do
      delete apex_org_doc_url(doc)
    end
    assert_redirected_to apex_org_docs_url
  end
end
