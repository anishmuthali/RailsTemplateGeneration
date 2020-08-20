require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get download" do
    get home_download_url
    assert_response :success
  end

end
