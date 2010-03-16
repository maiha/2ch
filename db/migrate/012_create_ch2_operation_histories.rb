class CreateCh2OperationHistories < Special::Migrations::Table
  column :type,       :string
  column :arg,        :string
  column :remote_ip,  :string
  column :flags,      :string
  column :created_at, :datetime
end
