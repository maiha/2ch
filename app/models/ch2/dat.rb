
class Ch2::Dat
  include Ch2::PrettyDebug

  attr_reader  :board

  dsl_accessor :dat_request  ,:default=>Ch2::Requests::Dat
  dsl_accessor :diff_request ,:default=>Ch2::Requests::DiffDat
  dsl_accessor :store_dir    ,:default=>"#{RAILS_ROOT}/dat"

  delegate     :site, :code,   :to=>:board
  delegate     :store_dir,     :to=>"self.class"
  delegate     :updated?,      :to=>:request

  class NotFound < StandardError; end

  def initialize(board)
    @board = board
  end

  # will be obsoleted soon
  def old_file
    dir = Pathname(store_dir) + site.host + site.code + code[0..3]
    dir.mkpath
    dir + "#{code}.dat"
  end

  def file
    dir = Pathname(store_dir) + site.id.to_s + site.code + board.created_at.strftime("%Y/%m/%d")
    dir.mkpath
    dir + "#{code}.dat"
  end

  def read
    if file.exist?
      @read ||= NKF.nkf('-Sw', File.read(file){}) # specify 'S' cause JRuby cannot detect encoding
    else
      raise NotFound, file.cleanpath.to_s
    end
  end

  def urls
    array = []
    read.scan(URI.regexp(["ttp"])){array << "h" + $&}
    return array
  end

  def exists?
    File.exists?(file)
  end

  def size
    exists? && File.size(file) || 0
  end

  def count
    read.count("\n")
  rescue
    0
  end

  def mtime
    File.mtime(file)
  end

  def partial_request?
    !@board.written_at.blank? && size > 1
  end

  def request
    caching {
      pretty_debug :partial_request? => partial_request?
      klass = partial_request? ? self.class.diff_request : self.class.dat_request
      klass.new(self)
    }
  end

  def messages(data = nil)
    data  = data ? NKF.nkf('-w', data) : read
    array = data.scan(%r{^(.*?)<>(.*?)<>(.*?)<>(.*?)<>(.*?)$})
    array.map{|a| Ch2::Message.new(*a[0,4])}
  end

  def one
    messages(file.open.readline)[0]
  end

  def created_at
    one.time
  rescue
    nil
  end

  def written_at
    messages.last.time
  rescue
    nil
  end

  def update_file(data, last_modified = nil)
    File.open(file, "w+") {|f| f.print data}
    touch(last_modified)
  end

  def append_file(data, last_modified = nil)
    File.open(file.to_s+".part", "w+") {|f| f.print data}
    File.open(file, "a") {|f| f.print data}
    touch(last_modified)
  end

  def touch(timestamp)
    if timestamp
      File.utime(timestamp, timestamp, file)
    end
  end

  def update
    pretty_debug Time.now.to_s
    request.execute
    if updated?
      board.updated
    end
  rescue => err
    pretty_debug :site=>site, :code=>code, :err=>err.message
    raise
  end
end
