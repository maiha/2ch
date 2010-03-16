class Ch2::Image::Fetched < Ch2::Image
  def size
    if path.exist?
      path.size
    else
      0
    end
  end
end
