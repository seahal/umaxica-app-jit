require "test_helper"

class Apex::Org::NewsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_org_news_index_url
    assert_response :success
  end

  test "should get new" do
    get new_apex_org_news_url
    assert_response :success
  end

  test "should create news" do
    assert_difference("News.count", 1) do
      post apex_org_news_index_url, params: { news: { title: "Test News" } }
    end
    assert_redirected_to apex_org_news_url(News.last)
  end

  test "should show news" do
    news = news(:one)
    get apex_org_news_url(news)
    assert_response :success
  end

  test "should get edit" do
    news = news(:one)
    get edit_apex_org_news_url(news)
    assert_response :success
  end

  test "should update news" do
    news = news(:one)
    patch apex_org_news_url(news), params: { news: { title: "Updated Title" } }
    assert_redirected_to apex_org_news_url(news)
  end

  test "should destroy news" do
    news = news(:one)
    assert_difference("News.count", -1) do
      delete apex_org_news_url(news)
    end
    assert_redirected_to apex_org_news_index_url
  end
end
