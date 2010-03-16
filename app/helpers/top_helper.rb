module TopHelper
  def thumbnail_link_with_stars(image)
    return thumbnail_link(image)

    # TODO

    point = [5, image.board_count / 2].min
    "%s<BR>%s" % [thumbnail_link(image), star_image * point]
  end
end
