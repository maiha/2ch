module TagHelper
  def keyword_image_count(keyword)
    keyword.image_count
  end

  def keyword_link_to_image(keyword)
    link_to "一覧", :controller=>"image", :action=>"tag", :id=>keyword
  end
end
