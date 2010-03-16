#  open("http://www.ruby-lang.org/en/",
#    "User-Agent" => "Ruby/#{RUBY_VERSION}",
#    "From" => "foo@bar.invalid",
#    "Referer" => "http://www.ruby-lang.org/") {|f|
#    ...

#load File.dirname(__FILE__) + '/../open-uri.rb'
require 'open-uri'
require 'zlib'
require 'ftools'
require 'logger'

class Ch2::Requests::Base
  include Ch2::PrettyDebug

  attr_reader  :url, :request_headers, :response_headers, :response_body, :status
  dsl_accessor :logger, :default=>proc{ Logger.new(RAILS_ROOT + "/log/request.log")}
  dsl_accessor :request_headers, :default=>{
    :read_timeout     => 60,
    "Accept-Encoding" => "gzip",
    "User-Agent"      => "Monazilla/1.00"
  }

  def initialize(url, headers = {})
    @url              = url
    @status           = url
    @request_headers  = build_request_headers(headers)
    @response_headers = nil
    @response_body    = nil
    @updated          = false
  end

  def gzip?
    /gzip/ === response_headers["content-encoding"].to_s
  end

  def last_modified
    Time.parse(response_headers["last-modified"])
  end

  def content_length
    @content_length || response_headers["content-length"].to_i
  end

  def partial_response?
    @status.first.to_i == 206
  end

  def ok_response?
    @status.first.to_i == 200
  end

  def updated?
    @updated
  end

  def http_access(url, request_headers)
    open(url, request_headers) {|f|
      @status           = f.status
      @response_headers = f.meta
      @response_body    = (gzip? ? Zlib::GzipReader.new(f) : f).read
      @content_length   = @response_body.size
    }
    @updated = true
  rescue OpenURI::HTTPError => err
    @updated = false
    debug "[#{err.class}] #{err}"
    raise
  end

  def execute
    before_execute

    debug url
    debug :request_headers=>request_headers
    http_access(url, request_headers)
    debug :status=>status, :response_headers=>response_headers

    after_execute
    return self
  end

private
  def build_request_headers(headers)
    self.class.request_headers.merge(headers)
  end

  def debug(value)
    pretty_debug value, self.class.logger, 2
  end

  def before_execute
  end

  def after_execute
  end
end
