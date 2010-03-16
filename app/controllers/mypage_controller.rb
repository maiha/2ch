class MypageController < ApplicationController
  before_filter :login_required
  nested_layout "mypage/layout"

  def index
  end

  ######################################################################
  ### Ajax
  def side

  end

end
