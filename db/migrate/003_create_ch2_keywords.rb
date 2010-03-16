class CreateCh2Keywords < Special::Migrations::Table
  column       :name,       :string
  column       :keyword,    :text
  column       :source,     :string
  column       :flags,      :string
end
