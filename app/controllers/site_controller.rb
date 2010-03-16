# -*- coding:utf-8-unix -*-

class SiteController < ApplicationController
  nested_layout

  def index
    redirect_to :action=>"list"
  end

  def list
    @sites = Ch2::Site.find(:all)
  end

  def keywords
    @keywords = Ch2::Keyword.find(:all, :order=>"name")
    @site = Ch2::Site.find(params[:id])
  end

  def update_keywords
    @site = Ch2::Site.find(params[:id])
    @site.positive_keyword_ids = params[:positive_keywords].keys
    @site.negative_keyword_ids = params[:negative_keywords].keys

    redirect_to :action=>"list"
  end

end
