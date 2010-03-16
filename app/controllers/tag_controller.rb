class TagController < ApplicationController
  nested_layout
  helper :site

  def index
#     counts_hash = Hash[*Ch2::Habtm::ImagesKeywords.count(:group=>:keyword_id).flatten]
#     @keywords = Ch2::Keyword.find(:all, :limit=>100)
#     @keywords.each do |keyword|
#       keyword[:image_count] = counts_hash[keyword.id]
#     end
    @keywords = Ch2::Keyword.find(:all, :count=>:images, :limit=>100, :conditions=>"image_count > 0")
  end
end
