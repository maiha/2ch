class Ch2::Parsers::Subback < Ch2::Parsers::Base
  def execute
    array = @html.scan(%r|<a href="(\d{10})/(.*?)">(\d+):(.*?)\((\d+)\)</a>|)
    array.collect do |number, postfix, index, name, res_count|
      Ch2::Bbs.new(:number=>number, :name=>name.to_s.strip)
    end
  end
end
