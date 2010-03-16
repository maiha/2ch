class Notice < ActiveRecord::Base
  class << self
    def current
      query = "((started_at IS NULL) OR (started_at <= ?)) AND ((stopped_at IS NULL) OR (stopped_at >= ?))"
      first(:conditions=>[query, Time.now, Time.now], :order=>"id DESC")
    end
  end
end
