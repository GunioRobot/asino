require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test "should get index" do
    get :index
    assert_redirected_to new_user_session_path unless current_user
  end

end
