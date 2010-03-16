class TopController < ApplicationController
  nested_layout
  helper :image
  helper :board

  caches_page :index

  def index
    @recent_images  = recent_images(8)
    @popular_images = popular_images(8)
    @weekly_images  = popular_images(8, Time.now.ago(1.week))
    @scored_images  = scored_images(8)
    @popular_boards = popular_boards(10)
    @clouded_tags   = tag_cloud
  end

  private
    def scored_images(limit = 10)
      Ch2::Image::Fetched.scored.all(:limit=>limit)
    end

    def recent_images(limit = 10)
      Ch2::Image::Fetched.all(:order=>"created_at DESC", :limit=>limit)
    end

    def popular_images(*args)
      Ch2::Image::Fetched.popular(*args)
    end

    def popular_boards(limit = 10)
      Ch2::Board.actives(:limit=>limit, :count=>:images)
    end

    def tag_cloud(min = 12, max = 38)
      keywords = Ch2::Keyword.all(:count=>:images, :conditions=>"image_count > 0")
      counts   = keywords.map(&:image_count)
      rate     = 1.0 * (max - min) / (counts.max - counts.min) rescue 0
      clouder  = (counts.blank? or counts.max == counts.min) ? proc{|c| min + (max - min)/2} :
        proc{|c| (min + (c - counts.min)*rate).ceil}

      keywords.each do |keyword|
        keyword[:size] = clouder.call(keyword.image_count)
      end

      keywords
    end
end
