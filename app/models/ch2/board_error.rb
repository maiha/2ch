class Ch2::BoardError < ActiveRecord::Base
  set_table_name :ch2_board_errors
  belongs_to       :board
end
