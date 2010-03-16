class Thumbnails::Base
  def initialize(size, src, dst = nil)
    @size = size
    @src  = Pathname(src)
    @dst  = Pathname(dst || (@src.parent  + "tn" + @src.basename).to_s)
  end

  def execute
    create_directory
    convert
  end

  private
    def create_directory
      @dst.parent.mkpath
    end

    def convert
      raise NotImplementedError, "subclass responsibility"
    end
end
