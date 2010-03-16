# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  helper   ImageHelper
  delegate :transaction, :sanitize_sql, :to=>"ActiveRecord::Base"
  helper_method :write_exception

  private
    def login_required
      if session[:user_id]
        begin
          @current_user = User.find(session[:user_id])
          return true
        rescue ActiveRecord::RecordNotFound
          flash[:notice] = "セッションがタイムアウトしました"
        end
      end
      @current_user = nil
      session[:user_id] = nil
      redirect_to new_session_url
      return false
    end

    def redirect_to(*args)
      if request.xhr?
        render :update do |page|
          page.redirect_to(*args)
        end
      else
        super
      end
    end

    def auto_render_message(message, level = :notice)
      erase_render_results
      if request.xhr?
        render :update do |page|
          page[:message].replace_html content_tag(:span, message.to_s, :class=>"notice")
        end
      else
        flash[level] = message
        redirect_to :controller=>"top", :action=>"index"
      end
    end

    def rescue_action(error)
      case error
      when ActiveRecord::RecordNotFound
        auto_render_message("指定されたデータは存在しません", :error)
      else
        logger.debug error.inspect
        logger.debug error.backtrace.join("\n") rescue nil
        if request.xhr?
          message = "申し訳ありません。エラーが発生しました。\n#{error}"
          auto_render_message(message, :error)
        else
          super
        end
      end
    end

end
