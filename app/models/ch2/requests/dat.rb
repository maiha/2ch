class Ch2::Requests::Dat < Ch2::Requests::Base
  attr_reader :dat
  delegate    :board, :file, :size,       :to=>:dat
  delegate    :site, :store_dir, :code,   :to=>:board

  def initialize(dat, headers={})
    @dat = dat
    raise "Missing board" unless board
    raise "Missing site"  unless site
    super(url, headers)
  end

  def url
    "http://%s/%s/dat/%s.dat" % [site.host, site.code, code]
  end

  def updated
    @updated = true
  end

private
  def before_execute
  end

  def after_execute
    if ok_response?
      dat.update_file(response_body, last_modified)
      updated
    end
  end

end
