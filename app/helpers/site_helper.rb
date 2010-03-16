module SiteHelper
  def ch2_site_link_to_edit_keywords(record)
    link_to "キーワード設定", :action=>"keywords", :id=>record
  end

  def keyword_positive_check_box(keyword)
    checked = @site.positive_keywords.any?{|obj| obj.id == keyword.id}
    check_box_tag "positive_keywords[#{keyword.id}]", "1", checked
  end

  def keyword_negative_check_box(keyword)
    checked = @site.negative_keywords.any?{|obj| obj.id == keyword.id}
    check_box_tag "negative_keywords[#{keyword.id}]", "1", checked
  end

  def keyword_name(keyword)
    h(keyword.name)
  end

  def keyword_keyword(keyword)
    h(keyword.source)
  end

end
