require 'rubygems'
#require 'image_science'

class Thumbnails::ImageScience < Thumbnails::Base
  class << self
    def convert(size, src, dst)
      success = nil
      ::ImageScience.with_image(src) do |img|
        img.thumbnail(size) do |thumb|
          success = thumb.save(dst)
        end
      end

      raise "cannot convert" unless success
    end
  end

  private
    def convert
      self.class.convert @size, @src, @dst
    end
end
