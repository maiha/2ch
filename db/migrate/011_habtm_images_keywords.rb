class HabtmImagesKeywords < Special::Migrations::Table
  habtm Ch2::Image, Ch2::Keyword, "ch2_habtm_images_keywords"
end
