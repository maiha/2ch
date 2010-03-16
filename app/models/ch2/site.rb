# -*- coding:utf-8-unix -*-

class Ch2::Site < ActiveRecord::Base
  set_table_name :ch2_sites
  habto            :positive_keyword, :join_table=>"ch2_habtm_sites_positive_keywords",
                   :association_foreign_key=>"keyword_id", :class_name=>"Ch2::Keyword"
  habto            :negative_keyword, :join_table=>"ch2_habtm_sites_negative_keywords",
                   :association_foreign_key=>"keyword_id", :class_name=>"Ch2::Keyword"
  has_many         :boards, :class_name=>"Ch2::Board"
  has_many         :active_boards, :class_name=>"Ch2::Board",
                   :conditions=>["position > 0"], :order=>"position"
  acts_as_bits     :flags, %w( live_update )

  dsl_accessor :default_parser, :default=>Ch2::Parsers::Subject

  def subject
    Ch2::Parsers::Subject.textize(active_boards)
  end

  def parser(*args)
    options = args.optionize :parser
    options[:positive] ||= positive_keywords
    options[:negative] ||= negative_keywords

    klass = options.delete(:parser) || self.class.default_parser
    klass.build(self, options)
  end

  def current_boards(*args)
    parser.execute
  end

  def liveupdate(options = {})
    Ch2::LiveUpdate.new(self, :dat=>true).execute
  end
end
