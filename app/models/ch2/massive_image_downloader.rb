class Ch2::MassiveImageDownloader
  delegate :logger, :to=>"ActiveRecord::Base"

  def initialize(images, options = {})
    @images  = images
    @options = options
    @locker  = Mutex.new
    @records = []
    @player  = nil
  end

  def option(key)
    @options[key] || __send__("default_#{key}")
  end

  def register_threads
    (option(:thread) - @threads.size).times do
      domain = @domains.shift or next
      images = @domain_grouped_images[domain]
      logger.debug "Creating new thread for domain [#{domain}](#{images.size} images)"
      thread = Thread.new(images, self) do |images, parent|
        images.each do |image|
          image.execute!(parent)
        end
      end
      @threads << thread
    end
  end

  def wait_for_player
    logger.debug "playerの終了を待っています"
    while not @records.empty?
      sleep 0.3
    end
    @player.kill
    @player = nil
    logger.debug "playerが終了しました"
  end

  def wait_for_recorders
    @threads.each {|th| th.join}
  end

  def wait_interval
    sleep option(:interval)
    @threads.delete_if{|th| !th.alive?}
  end

  def execute
    Thread.abort_on_exception = true

    @domain_grouped_images = @images.group_by(&:domain)
    @domains = @domain_grouped_images.keys
    @threads = []

    logger.debug "playerを開始します"
    @player = Thread.new{ play }

    while not @domains.empty?
      register_threads
      wait_interval
    end

    wait_for_recorders
    wait_for_player
  end

  def record(&block)
    @locker.synchronize do
      @records << block
    end
  end

  def play
    while true
      if @records.empty?
        sleep 0.3
      else
        block = @locker.synchronize{@records.shift}
        block.call
      end
    end
  end

private
  def default_thread
    10
  end

  def default_interval
    2
  end

end
