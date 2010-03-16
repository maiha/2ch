class HabtmBoardsImages < Special::Migrations::Table
  habtm Ch2::Image, Ch2::Board, "ch2_habtm_boards_images"
end
