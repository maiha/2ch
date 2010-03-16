class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :ch2_board_histories, :created_at
  end

  def self.down
    remove_index :ch2_board_histories, :created_at
  end
end
