# -*- coding:utf-8-unix -*-
class Admins::BoardController < ApplicationController
  # ext_paginate Ch2::Board, :edit=>true

  def created
    limit    = params[:limit] ? params[:limit].to_i : 5
    format   = (params[:format].blank?) ? "[name]" : params[:format].to_s
    keyword  = Ch2::Keyword.find_by_code(params[:code])
    createds = Ch2::BoardHistory::Created.find(:all, :include=>{"board"=>"site"}, :limit=>limit,
                                               :conditions=>["ch2_board_histories.created_at > ?", parse_since])
    boards   = createds.map(&:board)


    # filter
    boards = boards.select{|b| keyword.match?(b)} if keyword

    # output
    keys = Ch2::Board.column_names + %w( url site mark )
    text = boards.map{|b|
      begin
        b.summary(format)
      rescue => err
        "[%s] %s (%s)" % [err.class, err.message, (err.backtrace.first rescue '')]
      end
    }.join("\n")

    render :text => text
  rescue
    render :nothing => true
  end

  private
    def parse_since
      case params[:since].to_s
      when /\A(\d+)([DHM])\Z/i
        unit = {:d=>1.day, :h=>1.hour, :m=>1.minute}
        sec  = $1.to_i * unit[$2.downcase.intern]
        Time.now - sec
      when ''
        Time.now - 1.hour
      else
        params[:since]
      end
    end
end
