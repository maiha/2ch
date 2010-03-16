# -*- coding:utf-8-unix -*-

require 'uri'

class Ch2::Image < ActiveRecord::Base
  set_table_name :ch2_images
  habto          :board,   :join_table=>"ch2_habtm_boards_images",   :class_name=>"Ch2::Board"
  habto          :keyword, :join_table=>"ch2_habtm_images_keywords", :class_name=>"Ch2::Keyword"
  acts_as_bits   :flags, [:dirty]
  dsl_accessor   :image_dir, :default=>proc{ (Pathname(RAILS_ROOT) + "images").cleanpath }
  delegate       :exist?, :to=>"path"
  named_scope    :scored,  :conditions=>"score>0", :order=>"score desc"
  named_scope    :counted, :conditions=>"count>0", :order=>"count desc"
  before_create  :check_domain

  class NewRecordError < RuntimeError; end

  ######################################################################
  ### Instance creation

  class << self
    def for(url)
      Ch2::Image.find_by_url(url) || Ch2::Image::Request.create!(:url=>url)
    end

    def popular(limit = nil, created_at = nil)
      options = {
        :conditions => ["created_at >= ?", created_at || Time.now.yesterday],
        :order      => "board_count DESC",
        :limit      => limit || 10,
        :count      => :boards,
      }
      find(:all, options)

# Ch2::Image.find(:all, :count=>:boards, :conditions=>["created_at >= ?", Time.now.ago(1.week)], :limit=>5)
    end
  end

  ######################################################################
  ### Accessor methods

  def uri
    URI.parse(url)
  end

  def domain
    uri.host.split('.')[-2,2].join('.')
  rescue
    nil
  end

  def strip_protocol
    url.sub(%r{^http://}, '')
  end

  def prefix
    raise NewRecordError unless id
    id / 1000 * 1000
  end

  def ext
    url.split('.').last
  end

  def relative_path(tn = nil)
    raise NewRecordError unless id
    tn &&= "tn/"
    "%d/%s%d.%s" % [prefix, tn, id, ext]
  end

  def path(tn = nil)
    p = self.class.image_dir + relative_path(tn)
    p.parent.mkpath
    return p
  end

  def old_path
    self.class.image_dir + strip_protocol
  end

  def size
    nil
  end

  def basename
    File.basename(url)
  end

  ######################################################################
  ### Testing

  def invalid?
    self[:type] == "Invalid"
  end

  def fetched?
    self[:type] == "Fetched"
  end

  def improper?
    dirty? or score.to_i < -1
  end

  ######################################################################
  ### Images

  def thumbnail
    p = path
    p.dirname + "tn" + p.basename
  end

  def write_thumbnail(engine = Thumbnails::Convert)
    tn = thumbnail
    return false unless fetched?
    return false unless path.exist?
    return false if tn.exist?
    tn.dirname.mkpath
    src = path.to_s.delete(%{'"\\}) # "'
    dst = tn.to_s.delete(%{'"\\}) # "'

    engine.convert(100, src, dst)
    retype!(tn)
    return true
  rescue => err
    retype!(tn)
    return false
  end

  def write_digest(force = false)
    if path.exist? and (self[:digest].blank? or force)
      require 'digest/md5'
      self[:digest] = Digest::MD5.hexdigest(path.read{})
    end
  end

  ######################################################################
  ### Filtered

  def gai?
    !! gai
  end

  def gai
    self.class.first(:conditions=>["digest = ? AND created_at < ?", digest, created_at], :order=>"created_at DESC")
  end

  ######################################################################
  ### for STI

  def become!(type)
    type = type.to_s.classify
    unless self[:type] == type
      self[:type] = type
      save!
    end
  rescue => err
    message = "I want to be #{type}, but couldn't because #{err.message}. [#{err.class}]"
    logger.error message
    raise
  end

  def retype!(file = path)
    if file.exist?
      write_digest
      become! :fetched
    else
      become! :missing
    end
  end

  private
    def check_domain
      unless domain
        self[:type] = 'Invalid'
      end
      true
    end
end
