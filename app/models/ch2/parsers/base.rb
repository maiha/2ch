# -*- coding:utf-8-unix -*-

require 'open-uri'

class Ch2::Parsers::Base
  dsl_accessor :url
  dsl_accessor :request_headers, :default=>{
    "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.8.1.3) Gecko/20070309 Firefox/2.0.0.3",
  }

  attr_reader :options

  class << self
    def build(obj, options = {})
      url = target_url(obj)
      ActiveRecord::Base.logger.debug "#{self} Load from #{url}"
      headers = request_headers.merge(options.delete(:headers)||{})
      html    = open(url, headers).read
      new(html, options)
    end

    def parse(obj, options = {})
      build(obj, options).execute
    end

    def target_url(obj)
      case url
      when Array
        base, *methods = url
        base % methods.map{|i| obj.__send__(i)}
      else
        url.to_s
      end
    end
  end

  def initialize(html, options = {})
    @options = {:nkf=>"-w"}.merge(options).with_indifferent_access
    @html = html.to_s
    @html = NKF.nkf(@options[:nkf], @html) if @options[:nkf]
    @positives = strip_keyword(*@options[:positive])
    @negatives = strip_keyword(*@options[:negative])
    setup
  end

  def execute
    positive_filter(build_regexp(@positives))
    negative_filter(build_regexp(@negatives))
    instantiate
  end

  private
    def setup
      @lines = @html.split(/\r?\n/)
    end

    def build_regexp(keywords)
      source = keywords.map(&:source).join('|')
      if source.blank?
        nil
      else
        Regexp.compile(source, Regexp::IGNORECASE)
      end
    end

    def strip_keyword(*keywords)
      keywords.map do |keyword|
        case keyword
        when NilClass
          nil
        when Ch2::Keyword
          keyword.blank? ? nil : keyword
        else
          raise ArgumentError, "unknown keyword type: %s" % keyword.class
        end
      end.compact
    end

    def positive_filter(regexp)
      @lines = @lines.select{|i| regexp === i} if regexp
    end

    def negative_filter(regexp)
      @lines = @lines.reject{|i| regexp === i} if regexp
    end

    def instantiate
      raise NotImplementedError, "subclass responsibility"
    end
end
