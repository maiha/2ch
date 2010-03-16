# -*- coding:utf-8-unix -*-
module Ch2::Board::Yasusu
  module Marks
    YASU  = /｀\.∀´/o
    UME   = /´∀｀.*嘘/o
    PRESS = /近.*日.*記.*者/o
    P     = /P\Z/o
    Q     = /Q\Z/o
    K     = /O\Z/o
  end

  def detect_yasusu
    body   = dat.one.message
    sender = dat.one.created_at
    self.yasu  = Marks::YASU  === body
    self.ume   = Marks::UME   === body
    self.press = Marks::PRESS === body
    self.p     = Marks::P === sender
    self.q     = Marks::Q === sender
    self.k     = Marks::K === sender
    return true
  rescue Errno::ENOENT
    return false
  end

  def detect_yasusu!
    if detect_yasusu
      save!
    end
  end
end
