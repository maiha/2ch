class CreateCh2BoardErrors < Special::Migrations::Table
  column       :message,    :string
  column       :trace  ,    :string
  column       :created_at, :datetime
  belongs_to Ch2::Board
end
