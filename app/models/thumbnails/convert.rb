class Thumbnails::Convert < Thumbnails::Base
  class AnimationFound < RuntimeError; end

  class << self
    def convert(size, src, dst)
      cropped_thumbnail(size, src, dst)
    rescue => error
      unless error.is_a?(AnimationFound)
        ActiveRecord::Base.logger.error "[FAILED] Thumbnails::Convert.convert(#{size}, #{src}, #{dst}): #{error}"
      end
      thumbnail(size, src, dst)
    end

    def thumbnail(size, src, dst)
      command = "convert #{src} -thumbnail '#{size}x#{size}' #{dst}"
      system(command)
    end

    def cropped_thumbnail(size, src, dst) # :yields: image
      infos = `identify -format "%w %h " #{src}`.chomp.split
      raise AnimationFound if infos.size > 2

      w = infos.shift.to_i
      h = infos.shift.to_i

      raise "width  is not > 0" unless w > 0
      raise "height is not > 0" unless h > 0

      l, t, r, b, half = 0, 0, w, h, (w - h).abs / 2

      l, r = half, half + h if w > h
      t, b = half, half + w if h > w

      command = "convert #{src} -crop '#{r-l}x#{b-t}+#{l}+#{t}' -thumbnail '#{size}' #{dst}"
      system(command)
    end
  end

  private
    def convert
      self.class.convert(@size, @src, @dst)
    end
end
