class CreateCh2Boards < Special::Migrations::Table
  column :name,       :string
  column :code,       :string
  column :count,      :integer
  column :dat_size,   :integer
  column :position,   :integer
  column :flags,      :string
  column :created_at, :datetime
  column :written_at, :datetime

  index  [:site_id, :code]

  belongs_to Ch2::Site
end
