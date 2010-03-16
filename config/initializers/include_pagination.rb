ActiveRecord::Base.class_eval do
  include PaginationScope
end
