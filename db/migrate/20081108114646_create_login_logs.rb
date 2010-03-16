class CreateLoginLogs < ActiveRecord::Migration
  def self.up
    create_table :login_logs do |t|
      t.string :user
      t.boolean :result
      t.string :ip_address
      t.string :info
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :login_logs
  end
end
