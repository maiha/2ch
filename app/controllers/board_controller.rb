class BoardController < ApplicationController
  nested_layout

  caches_page :index, :show

  def index
#     @boards = Ch2::Board.find_by_sql(<<-SQL)
# SELECT id, name, code, position, count(*) AS cnt
# FROM ch2_boards
# LEFT OUTER JOIN ch2_habtm_boards_images ON ch2_habtm_boards_images.board_id = ch2_boards.id
# WHERE (position > 0)
# GROUP BY id, code, name, position
# ORDER BY position
#     SQL

    @boards = Ch2::Board.find(:all, :conditions=>"position > 0", :order=>"position", :count=>:images)
  end

  def show
    if params[:id].to_s.include?(':')
      bid, mid = params[:id].split(':').map(&:to_i)
      return render_one_message(bid, mid)
    end

    @board = Ch2::Board.find(params[:id])
    @dat   = @board.dat
    unless @dat
      render :text=>"no dat"
    end
  end

  private
    def render_one_message(bid, mid)
      board = Ch2::Board.find(bid)

      u2i  = board.images.index_by(&:url)
      m    = board.messages[mid-1]
      html = m.message
      urls = []
      html.scan(URI.regexp(["http", "ttp"])){
        url = $&.sub(%r{^h?ttp://?}, 'http://')
        image = u2i[url] or next
        image.fetched?   or next
        @image = image
        urls << render_to_string(:inline=>"<%=full_image_path_without_asset(@image)%>")
      }

      @args = [m, mid, true]
      content = render_to_string(:inline=>"<%= render_message_for(*@args) %>")

      command = urls.map{|i| "cp %s ." % File.join(RAILS_ROOT, "public", i)}.join("\n")
      render :text => "#{content}<pre>#{command}</pre>"
    end
end
