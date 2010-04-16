module BoardHelper
  def board_no(board = @board)
    html = h(board.position)
    html = content_tag(:div, html, :class=>"advisory") if board.position > 600
    html
  end

  def board_code(board = @board)
    h(board.code)
  end

  def board_name(board = @board)
    h(board.name)
  end

  def board_count(board = @board)
    h(board.count)
  end

  def board_vigor(board = @board)
    h(board.vigor)
  end

  def board_url(board = @board)
    h(board.url)
  end

  def board_status(board = @board)
    if board.position > 0
      content_tag :span, "active", :style=>"color:tomato;font-weight:bold;"
    else
      board.count < 1000 ? "dat落ち" : "1000"
    end
  end

  def board_range(board = @board)
    time1 = @board.created_at.strftime("%Y-%m-%d %H:%M") rescue '???'
    time2 = @board.written_at.strftime("%Y-%m-%d %H:%M") rescue '???'
    time2 = "" if board.position > 0
    "%s～%s" % [time1, time2]
  end

  def render_messages(board = @board, opts = {})
    images = board.images.index_by(&:url)
    regexp = URI.regexp(["http", "ttp"])
    buffer = opts[:buffer] || board.dat.read{} # sjis

    # strip referer link tags
    buffer.gsub!(%r{<a href=".*?" target="_blank">&gt;&gt;(\d+)</a>}) do
      %Q{<a href="#r#{$1}">&gt;&gt;#{$1}</a>}
    end

    buffer = buffer.gsub(regexp) do
      url = $&.sub(%r{^h?ttp://?}, 'http://')
      case url
      when %r{\.(jpg|jpeg|gif|bmp|png)$}oi
        image = images[url]
      end
      if image and image.fetched?
        thumbnail_link(image)
      else
        url
      end
    end

    html = ''
    board.messages(buffer).each_with_index do |m, i|
      has_image = m.message.to_s.include?('<a href="/image/show/')
      html << render_message_for(m,i,has_image)
    end
    return html
  rescue Ch2::Dat::NotFound
    render :partial=>"board/dat_not_found"
  end

  def render_message_for(message, i, image)
    name = message.name
    mail = h(message.email)
    time = h(message.created_at)
    body = message.message
    style = image ? "image" : "word"
    format(<<-EOF, i+1, style, i+1, i+1, name, mail, time, style, body)
<dt id="r%d" class="%s"><a name="r%d"></a>
<span class="spmSW">%d</span>：
<span class="name"><b>%s</b></span>：
<span class="email"><b>%s</b></span>：
%s
</dt>
<dd class="%s">%s<br/><br/></dd>
    EOF
  end

  def board_link_to_image(board = @board)
    count = board.images.count
    if count > 0
      link_to h(count), :controller=>"image", :action=>"board", :id=>board
    else
      '-'
    end
  end

  def board_count_link(board = @board)
    link_to board_count(board), :controller=>"board", :action=>"show", :id=>board
  end

  def board_link_to_board(board = @board)
    label = board.code
    link_to label, :controller=>"board", :action=>"show", :id=>board
  end

  def board_link_to_2ch(board = @board)
    link_to "2ch", original_board_url(board)
  end

  def board_link_to_wota(board = @board)
    link_to "wota", wota_board_url(board)
  end
end
