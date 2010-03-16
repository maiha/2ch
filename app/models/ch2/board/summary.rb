# -*- coding:utf-8-unix -*-
module Ch2::Board::Summary
  def summary(format)
    format.gsub(/\[(.*?)\]/) {
      case (key = $1)
      when 'site'   then "[%s]" % site.name
      when 'mark'
        {
          :yasu  => '保',
          :ume   => '梅',
          :press => '記者',
          :p     => 'P',
          :q     => 'Q',
          :k     => '携',
        }.inject('') {|buf, (flag, mark)|
          buf << "[#{mark}]" if flag?(flag)
          buf
        }
      when *Ch2::Board.column_names
        self[key].to_s
      else
        $&
      end.to_s
    }
  rescue => err
    ActiveRecord::Base.logger.error "Ch2::Board#summary: #{err.class} #{err.message}"
    raise
  end
end
