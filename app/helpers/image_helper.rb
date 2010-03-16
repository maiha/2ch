module ImageHelper
  include BoardHelper

  def image_style(image)
    return "dirty" if image.improper?
    ""
  end

  def thumbnail_tag(image)
    return nil unless image

    tn = full_image_path(image, true)
    image_tag tn.to_s, :class=>image_style(image)
  end

  def thumbnail_link(image)
    tn = thumbnail_tag(image)
    link_to tn, :controller=>"image", :action=>"show", :id=>image
  rescue
    nil
  end

  def full_image_path(image, tn = nil)
    "i/" + image.relative_path(tn)
  end

  def full_image_path_without_asset(image)
    image_path(full_image_path(image)).sub(%r{\?.*?\Z}, '')
  end

  def full_image_url(image)
    "#{request.protocol}#{request.host_with_port}#{full_image_path_without_asset(image)}"
  end

  def link_to_image(image)
    path = full_image_path_without_asset(image)
    link_to path, url_for(path)
  end

  def full_image_tag(image)
    image_tag full_image_path(image), :class=>image_style(image)
  end

  def original_board_url(board)
    "http://wota.jp/r/%s" % board.code
  end

  def wota_board_url(board)
    "http://wota.jp/m/%s" % board.code
  end

  def link_to_tags(tags)
    links = tags.map{|tag|
      title = "[%s]" % h(tag.name)
      link_to title, :action=>"tag", :id=>tag
    }.join("&nbsp;&nbsp;")
  end

  ######################################################################
  ### Rating

  def image_score_with_link(image)
    target = "image_%d_score" % image.id
    link = proc{|action|
      "jQuery('#%s').load('/image/%s/%d',{%s:'%s'});" %
      [target, action, image.id, request_forgery_protection_token, escape_javascript(form_authenticity_token)]
    }
    score = content_tag(:span, javascript_tag(link.call(:score)), :id=>target)
    good  = link_to_function "&nbsp;", link.call(:good), :class=>"ox o-link"
    bad   = link_to_function "&nbsp;", link.call(:bad ), :class=>"ox x-link"

    score + content_tag(:div, good + bad, :class=>"op-votes")
  end

  ######################################################################
  ### Popular

  def popular_links(*ranges)
    unit_names = {
      'day'    => '日',
      'week'   => '週間',
      'month'  => 'ヶ月',
      'hour'   => '時間',
      'minute' => '分',
    }

    lis = []
    ranges.flatten.each do |id|
      case id.to_s
      when /^(\d+)(#{unit_names.keys*('|')})$/o
        num, unit = $1, $2
        num   = [1, num.to_i].max
        sec   = num.send(unit)
        name  = "%d%s" % [num, unit_names[unit]]
        style = (sec == @range) ? "on" : ""
        link  = link_to name, :id=>id
        lis << content_tag(:li, link, :class=>style)
      end
    end
    return content_tag(:ul, lis.join, :class=>"logical popular_image")
  end

  ######################################################################
  ### History

  def image_history(image)
    gai = image.gai
    if gai
      at = gai.created_at
      text = at.strftime("%Y-%m-%d にとっくにガイシュツ")
      content_tag(:span, text, :class=>"gai")
    elsif image.boards.count > 1
      content_tag(:span, "新作", :class=>"new")
    else
      content_tag(:span, "最新作！", :class=>"uniq")
    end
  end

end
