# -*- coding:utf-8-unix -*-

class Ch2::Board < ActiveRecord::Base
  set_table_name :ch2_boards
  belongs_to       :site, :class_name=>"Ch2::Site"
  has_many         :histories, :class_name=>"Ch2::BoardHistory"
  habto            :image,   :join_table=>"ch2_habtm_boards_images",
                   :association_foreign_key=>"image_id", :class_name=>"Ch2::Image"
  habto            :keyword, :join_table=>"ch2_habtm_boards_keywords",
                   :association_foreign_key=>"keyword_id", :class_name=>"Ch2::Keyword"
  acts_as_bits     :flags, %w( yasu ume press p q k )

  delegate :messages, :to=>:dat

  include Yasusu
  include Summary

  class << self
    def actives(options = {})
      options = options.merge(:conditions=>"position > 0", :order=>"position")
      find(:all, options)
    end
  end

  def url
    "http://%s/test/read.html/%s/%s" % [site.host, site.code, code]
  end

  def dat
    @dat ||= Ch2::Dat.new(self)
  end

  def subject
    Ch2::Parsers::Subject.textize(self)
  end

  def vigor
    ((1.day.to_f * self[:count].to_i) / ((written_at||Time.now) - created_at)).ceil
  rescue
    0
  end

  def updated
    self[:dat_size] = dat.size
    self[:count]    = dat.count
    if time = dat.created_at
      self[:created_at] = time
    end
    if time = dat.written_at || dat.mtime
      self[:written_at] = time
    end
    save!
  end

  def drop!
    self.position = -1
    save!
  end

  def link_image(image)
    unless image_ids.include?(image.id)
      image.keyword_ids = (image.keyword_ids | keyword_ids).uniq
      images << image
    end
  end
end
