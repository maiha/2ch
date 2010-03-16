# -*- coding:utf-8-unix -*-

class Ch2::Keyword < ActiveRecord::Base
  set_table_name :ch2_keywords
  habto  :positive_keyword, :join_table=>"ch2_habtm_sites_positive_keywords",
         :association_foreign_key=>"site_id", :class_name=>"Ch2::Site"
  habto  :negative_keyword, :join_table=>"ch2_habtm_sites_negative_keywords",
         :association_foreign_key=>"site_id", :class_name=>"Ch2::Site"
  habto  :board, :join_table=>"ch2_habtm_boards_keywords", :class_name=>"Ch2::Board"
  habto  :image, :join_table=>"ch2_habtm_images_keywords", :class_name=>"Ch2::Image"

#  acts_as_bits     :flags, %w( regexp strip )

  def regexp
    @regexp ||= Regexp.compile(source.to_s, Regexp::IGNORECASE)
  end

  def keyword=(value)
    returning(super){ update_source }
  end

  ######################################################################
  ### Testing

  def blank?
    source.blank?
  end

  def match?(string)
    regexp === string.to_s.gsub(/(?:\s|　)+/, '')  # 空白あり
  end

  def filter(lines)
    lines.select{|i| match?(i)}
  end

  private
    def update_source
      words = self[:keyword].to_s.strip.split(/(?:\s|　)+/)  # 空白あり
      self[:source] = words.map{|word| Regexp.escape(word)}.join('|')
      @regexp = nil
    end

end
