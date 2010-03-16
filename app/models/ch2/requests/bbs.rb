class Ch2::Requests::Bbs < Ch2::Requests::Base
  attr_reader :board
  delegate    :site, :store_dir, :code, :to=>:board

  def initialize(board, headers={})
    @board = board
    super(url, headers)
  end

  def bbs_url
    "http://%s/test/read.cgi?bbs=%s&key=%s" % [site.host, site.code, code]
  end

  def update
    execute
  end
end
