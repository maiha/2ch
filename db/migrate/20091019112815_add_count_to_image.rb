class AddCountToImage < ActiveRecord::Migration
  def self.up
    add_column :ch2_images, :count, :integer, :default=>0
  end

  def self.down
    remove_column :ch2_images, :count
  end
end
