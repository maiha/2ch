class CreateCh2Sites < Special::Migrations::Table
  column :name,       :string
  column :code,       :string
  column :host,       :string
  column :flags,      :string
  column :created_at, :datetime
  column :updated_at, :datetime
end
