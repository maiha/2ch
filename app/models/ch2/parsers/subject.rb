# -*- coding:utf-8-unix -*-

class Ch2::Parsers::Subject < Ch2::Parsers::Base
  url ["http://%s/%s/subject.txt", :host, :code]

  class << self
    def textize(board)
      if board.is_a?(Array)
        board.map{|i| textize(i)}.join
      else
        "%s.dat<>%s(%d)\n" % [board.code, board.name, board.count]
      end
    end
  end

  def positions
    caching {
      regexp = %r{^(\d{10})\.dat}
      hash = {}
      @html.scan(regexp).each_with_index do |(code,), i|
        hash[code] = i+1
      end
      hash
    }
  end

  private
    def setup
      positions
      super
    end

    def instantiate
      html = @lines.is_a?(Array) ? @lines.join("\n") : @lines.to_s
      regexp = %r{^(\d{10})\.dat<>(.*?)\s*\((\d+)\)$}
      html.scan(regexp).map do |code, name, count|
        pos = positions[code] || -1
        build_board :code=>code, :name=>name, :count=>count, :position=>pos
      end
    end

    def build_board(attributes)
      returning(Ch2::Board.new(attributes)) do |board|
        board.keywords = @positives.select{|k| k.match?(board.name)}
      end
    end
end
