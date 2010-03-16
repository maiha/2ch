class HabtmBoardsKeywords < Special::Migrations::Table
  habtm Ch2::Keyword, Ch2::Board, "ch2_habtm_boards_keywords"
end
