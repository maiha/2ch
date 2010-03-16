class ImageController < ApplicationController
  nested_layout
  caches_page :index, :tag, :board, :popular, :show
  protect_from_forgery :only=>[:score, :good, :bad]
  verify :method=>:post, :only=>[:score, :good, :bad]

  def index
    options = {
      :order    => "created_at DESC",
      :per_page => 40,
      :page     => params[:page]
    }
#    @pages, @images = paginate Ch2::Image::Fetched, options
    @images = Ch2::Image::Fetched.paginate(options)
  end

  def tag
    @limit   = 100
    @keyword = Ch2::Keyword.find(params[:id])
    @images  = @keyword.images.find(:all, :conditions=>{:type=>"Fetched"}, :order => "created_at DESC", :limit=>@limit)
  end

  def board
    @limit  = 100
    @board  = Ch2::Board.find(params[:id])
    @images = @board.images.find(:all, :conditions=>{:type=>"Fetched"}, :order => "created_at DESC", :limit=>@limit)
  end

  def popular
    @range  = popular_range
    @images = Ch2::Image::Fetched.popular(50, Time.now.ago(@range))
  end

  def ranking
    @images = Ch2::Image::Fetched.scored.all(:limit=>50)
  end

  def famous
    @images = Ch2::Image::Fetched.counted.all(:limit=>50)
  end

  def show
    @image  = Ch2::Image::Fetched.find(params[:id])
    @boards = @image.boards.sort_by(&:code)
    @tags   = @image.keywords
  end

  def status
    code = (params[:id].to_i rescue 0)
    code = 500 if code == 0
    path = RAILS_ROOT + "/public/images/status/#{code}.png"
    send_file path, :type => 'image/png', :disposition => 'inline'
  end

  def bang
    raise "Invalid request" unless request.post?

    id = params[:id].to_s.sub(/^image_/, '')
    @image = Ch2::Image::Fetched.find(id)
    unless @image.dirty?
      transaction do
        @image.dirty = true
        @image.save!
        Ch2::OperationHistory::Bang.execute(@image, request.remote_ip)
        expire_page :action => "show", :id => @image.id
      end
    end

    render :update do |page|
      page << "$('##{params[:id]}').addClass('dirty');"
    end
  end

  ######################################################################
  ### REST actions

  def score
    render :text=>current_image.score.to_i.to_s
  rescue => e
    render :text=>h(e.to_s)
  end

  def good
    Ch2::Image.increment_counter :score, params[:id].to_i
    expire_page :action=>"show", :id=>params[:id]
    score
  end

  def bad
    Ch2::Image.decrement_counter :score, params[:id].to_i
    expire_page :action=>"show", :id=>params[:id]
    score
  end

  def count
    Ch2::Image.increment_counter :count, params[:id].to_i
    render :nothing=>true
  end

  ### Development

  def test
    @images = Ch2::Image::Fetched.popular(32, Time.now.ago(1.week))
  end

  def test2
    @images = Ch2::Image::Fetched.popular(10)
  end

private
  def guard_from_nested_layouts
    if %w( status count score good bad ).include?(action_name)
      true
    else
      super
    end
  end

  def current_image
    Ch2::Image::Fetched.find(params[:id])
  end

  def popular_range
    case params[:id].to_s
    when /^(\d*)(day|week|month|hour|minute)$/ then
      num, unit = $1, $2
      num = [1, num.to_i].max
      num.send(unit)
    else
      1.week
    end
  end

  private
    def verified_request?
      !protect_against_forgery?     ||
        request.method == :get      ||
#      request.xhr?                ||
        !verifiable_request_format? ||
        form_authenticity_token == params[request_forgery_protection_token]
    end

    def form_authenticity_token
      session[:_csrf_token] = '910'
    end
end
