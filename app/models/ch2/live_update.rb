class Ch2::LiveUpdate
  attr_reader :options, :current, :created, :dropped, :errors
  delegate    :transaction, :to=>"@options[:site]"

  def initialize(*args)
    @options = args.optionize :site, :update_dat, :keywords
    @current = []
    @created = []
    @dropped = []
    @errors  = []
  end

  def keywords
    @options[:keywords] || site.keywords
  end

  def site
    options[:site]
  end

  def coded_active_boards
    returning hash = site.active_boards.group_by(&:code) do
      hash.keys.each do |key|
        hash[key] = hash[key].first
      end
    end
  end

  def update_dat(board)
    board.dat.update
  rescue => err
    begin
      attributes = {
        :board_id => board.id,
        :message  => err.message,
        :trace    => (err.backtrace[0] rescue nil),
      }
      @errors << Ch2::BoardError.create!(attributes)
    rescue => err2
      message = "Got following error while writing data=>[%s]\nerror: %s" % [attributes.inspect, err2.inspect]
      ActiveRecord::Base.logger.error message
    end
  end

  def current_boards_for(site)
    boards = site.parser.execute     # このboardsはnew_record状態

    # 同じコードで登録されている場合はそちらに内容をコピーする
    boards.map do |board|
      existed = site.boards.find_by_code(board.code)
      if existed
        # see Ch2::Parsers::Subject
        [:code, :name, :count, :position].each do |key|
          existed[key] = board[key]
        end
        # keywordsのコピーは不要 (同じものであるはずだから)
        existed
      else
        board
      end
    end
  end

  def execute
    actives = coded_active_boards
    keepeds = {}

    ActiveRecord::Base.logger.debug site.parser.options.inspect
    @current = current_boards_for(site)

    transaction do
      @current.map! do |board|
        board.site = site
        active = actives.delete(board.code)
        if active
          # active board
          active.position = board.position
          keepeds[active.code] = active
          active
        else
          # new board
          board.save!
          @created << board
          Ch2::BoardHistory::Created.create!(:board_id=>board.id)
          board
        end
      end

      # dropped board
      actives.values.each do |board|
        board.drop!
        @dropped << board
        Ch2::BoardHistory::Dropped.create!(:board_id=>board.id)
      end
    end

    if options[:update_dat]
      transaction do
        @current.each do |board|
          update_dat(board)
          after_update_dat(board)
          if board.dat.updated? and keepeds[board.code]
            Ch2::BoardHistory::Updated.create!(:board_id=>board.id)
          end
        end
      end
    end

    return self
  end

  def after_update_dat(board)
    block = @options[:after_update_dat]
    if block.is_a?(Proc)
      block.call(board, self)
    end
  end

end
