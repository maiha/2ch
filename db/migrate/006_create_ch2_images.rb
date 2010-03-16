class CreateCh2Images < Special::Migrations::Table
  column :url,        :string
  column :type,       :string
  column :flags,      :string
  column :created_at, :datetime

  index :url
end
