class SessionsController < ApplicationController
  nested_layout "sessions/layout"

  def new
    if session[:user_id]
      flash.now[:notice] = "ログアウトしました"
    end
    session[:user_id] = nil
  end

  def create
    open_id_authentication
  end

  protected
    def password_authentication(name, pass)
      if @current_user = @account.users.authenticate(params[:user], params[:pass])
        successful_login
      else
        failed_login "Sorry, that username/password doesn't work"
      end
    end

    def open_id_authentication
      authenticate_with_open_id do |result, identity_url|
        if result.successful?
          if @current_user = User.register(identity_url)
            successful_login
          else
            failed_login "Sorry, no user by that identity URL exists (#{identity_url})"
          end
        else
          failed_login result.message
        end
      end
    end

  private
    def successful_login
      session[:user_id] = @current_user.id
      redirect_to :controller=>"mypage"
      login_log(true)
    end

    def failed_login(message)
      flash[:error] = message
      redirect_to(new_session_url)
      login_log(false)
    end

    def login_log(result)
      LoginLog.create :user=>params['openid.identity'], :result=>result, :ip_address=>request.remote_ip
    rescue => err
      log_error(err)
    end

end
