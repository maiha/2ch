# -*- coding:utf-8-unix -*-
module ApplicationHelper
  include ActiveRecordView::Helper # active_record_view plugin

  def register_sniper
    @sniper_comes = true
  end

  ######################################################################
  ### Current users

  def login_name
    if login?
      @current_user.to_label
    else
      'ゲスト'
    end
  end

  def login?
    !!@current_user
  end

  ######################################################################
  ### Popular

  def vigor_board_name
    latest = Ch2::BoardHistory::Created.find(:first, :order=>"created_at desc",
     :conditions=>["created_at > ?", Time.now.ago(10.minutes)])
    board = latest.board if latest

    unless board
      boards = Ch2::Board.actives.sort_by(&:vigor)
      if boards.blank?
        return h("狼が見えない (ネットワーク障害 or 規制 or 鯖移転)")
      end

      boards.reject!{|b| /(スレ|コン)/ === b.name.to_s}
      if boards.blank?
        return h("何か様子がヘンです (actives:#{boards.size})")
      end

      board = boards.last
    end

    name = board.name

    # strip vorbose marks
    name = name.gsub(/【.*?】/,'')
    name = name.gsub(/(スレ|[a-z]+|[\d\.]+|(　|\s)+)+$/i,'')
    # human hack
    name = name.gsub(/件$/, '')
    name = name.gsub(/　/, '')

    name.strip!
    truncate(name, :length=>24)

    link_to name, :controller=>"image", :action=>"board", :id=>board

  rescue => err
    controller.send :log_error, err
    err.message
  end

  def popular_image
    counts = Ch2::Habtm::BoardsImages.count(:group=>:image_id, :order=>"count_all desc", :limit=>10)
    if counts.blank?
      return nil
    else
      ids = counts.keys
      id  = ids[rand(ids.size)]
      return Ch2::Image.find(id)
    end
  end

  def logo_image
#    thumbnail_tag(popular_image)
    images = Ch2::Image::Fetched.popular(30, Time.now.ago(3.days))
    images.reject!(&:improper?)
    image  = images[rand(images.size)]
    html   = thumbnail_tag(image)
    link_to html, :controller=>"image", :action=>"show", :id=>image
  end

  def star_image
    image_tag("star.gif")
  end

  def images_last_modified_at
    time = [Ch2::Image.maximum(:created_at), Ch2::Board.maximum(:written_at)].max
    time.strftime("%Y-%m-%d %H:%M:%S")
  rescue
    '???'
  end

  ######################################################################
  ### Navigations and Tabs

  def oneline_message(message, css_class)
    return nil if message.blank?
    message  = message.strip
    summary, = message.split(/\r?\n/, 2)
    if summary == message
      html = summary
    else
      pre  = content_tag('pre', message)
      tips = content_tag('div', pre, :class=>"tips")
      html = "%s&nbsp;%s" % [summary, content_tag('a', "[詳細]" + tips, :href=>'#'
)]
    end
    return content_tag('span', html, :class=>css_class)
  end

  def current_menu?(args)
    case (target = args.last)
    when :id
      args.pop
      args[0,3] == [controller.controller_name.to_s, action_name.to_s, params[:id].to_s]
    when :action
      args.pop
      args[0,2] == [controller.controller_name.to_s, action_name.to_s]
    when :controller, Array, Regexp
      args.pop === controller.controller_name.to_s
    when TrueClass, FalseClass
      args.pop
    else
      args.first.to_s == controller.controller_name.to_s
    end
  end

  def tab_menu(name, *args)
    selected = current_menu?(args)
    options  = args.optionize(:controller, :action, :id)
    html     = link_to h(name), options.to_hash
    style    = selected ? "on" : ""

    content_tag :li, html, :class=>style
  end

  def navigate_link(*args)
    html = (args.size > 1) ? link_to(*args) : h(args.first)
    content_tag :span, html, :class=>"navigate_link"
  end

  def navigate_for(order)
    case order
    when Class
      if order.ancestors.include?(Order)
        label = order_name_for(order)
        url   = {:controller=>order.symbol, :action=>"list"}
      end
    when Order
      label = "%s(%s)" % [order.company.name, order.human_value(:client)]
      url   = {:controller=>order.symbol, :action=>"show", :id=>order}
    end
    if label and url
      navigate_link h(label), url
    else
      nil
    end
  end

  ######################################################################
  ### Image

  def css_image_class(image)
    board = image.boards.count > 1 ? '' : 'uniq'
    gai   = image.gai ? 'gai' : 'hatu'
    "%s %s" % [board, gai]
  end
end

