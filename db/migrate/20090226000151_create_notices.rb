class CreateNotices < Special::Migrations::Table
  column :body,       :string
  column :started_at, :datetime
  column :stopped_at, :datetime
end
