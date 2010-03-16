class CreateCh2BoardHistories < Special::Migrations::Table
  column       :type,    :string
  column       :count,   :integer
  column       :created_at, :datetime
  belongs_to Ch2::Board
end
