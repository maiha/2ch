class Ch2::BoardHistory < ActiveRecord::Base
  set_table_name :ch2_board_histories
  belongs_to :board
end
