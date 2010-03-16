class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :user
      t.string :pass
      t.string :flags
      t.string :name
      t.integer :exp
      t.datetime :logined_at
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :users
  end
end
