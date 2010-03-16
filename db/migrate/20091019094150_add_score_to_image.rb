class AddScoreToImage < ActiveRecord::Migration
  def self.up
    add_column :ch2_images, :score, :integer, :default=>0
  end

  def self.down
    remove_column :ch2_images, :score
  end
end
