# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
require 'pathname'


######################################################################
### Global variables
######################################################################

code      = "morningcoffee"
path      = Pathname("morningcoffee")
base_url  = "http://wota.jp/morningcoffee"
image_dir = "images"
test_url  = "http://www.google.com/"

######################################################################
### for 2ch module
######################################################################

namespace "2ch" do

  ######################################################################
  ### Global methods

  def current_sites
    Ch2::Site.find(:all, :conditions=>{:live_update=>true})
  end

  def query_cache(&block)
    ActiveRecord::Base.disable_cache_logging = true if ActiveRecord::Base.respond_to?(:disable_cache_logging)
    ActiveRecord::Base.cache(&block)
  end

  ######################################################################
  ### Test

  task "test:openuri" => "environment" do
    req = Ch2::Requests::Base.new(test_url)
    req.execute
  end

  task "test:openuri:lib" do
    require 'open-uri'

    request_headers = {
      :read_timeout     => 60,
      "Accept-Encoding" => "gzip",
      "User-Agent"      => "Monazilla/1.00"
    }

    begin
      open(test_url, request_headers) {|f|
        @status           = f.status
        @response_headers = f.meta
      }
    rescue ArgumentError => e
      case e.message.to_s
      when /unrecognized option: read_timeout/
        puts "You should replace open-uri.rb by rubygem version."
        puts "  cp /usr/lib/ruby/1.8/rubygems/open-uri.rb /usr/lib/ruby/1.8/"
      end
      raise
    end
  end


  ######################################################################
  ### Data

  task "update:dat" => "environment" do
    current_sites.each do |site|
      options = {
        :update_dat       => true,
        :after_update_dat => proc{|board, update|
          if update.created.include?(board)
            board.detect_yasusu! rescue nil
          end
        },
      }
      query_cache {
        update = Ch2::LiveUpdate.new(site, options)
        update.execute
      }
    end
  end

  task "install:dat" => "environment" do
    current_sites.each do |site|
      src  = Pathname(Ch2::Dat.store_dir).cleanpath + site.host + site.code
      dst  = "#{path}/dat"
      if path.exist?
        system "rsync -a #{src}/ #{dst}/"
      end
    end
  end

  task "update:data" do
#    Rake::Task["2ch:test"].invoke
    Rake::Task["2ch:update:dat"].invoke
    Rake::Task["2ch:install:dat"].invoke
  end


  ######################################################################
  ### Images

  task "request:image" => "environment" do
    require 'uri'

    query_cache {
      sites = Ch2::Site.find(:all, :include=>{:active_boards=>:site}, :conditions=>{:live_update=>true})
      sites.each do |site|
        boards = site.active_boards
        regexp = URI.regexp(["ttp"])

        boards.each do |board|
          next unless board.dat.exists?
          done = {}
          board.dat.read.scan(regexp) do
            case url = $&.sub(%r{^h?ttp://?}, 'http://')
            when %r{\.(jpg|jpeg|gif|bmp|png)$}oi
              done[url] ||= returning(Ch2::Image.for(url)) {|image|
                board.link_image(image) unless image.invalid?
              }
            end
          end
        end
      end
    }
  end

  task "fetch:image" => "environment" do
    dir = Pathname(RAILS_ROOT) + image_dir
    dir.mkpath
    Dir.chdir(dir) do
      images = Ch2::Image::Request.find(:all)
      downloader = Ch2::MassiveImageDownloader.new(images, :thread=>10)
      downloader.execute
      images.each{|i| i.write_thumbnail Thumbnails::Convert}
    end
  end

  task "update:image" do
    Rake::Task["2ch:request:image"].invoke
    Rake::Task["2ch:fetch:image"].invoke
  end


  ######################################################################
  ### Sites

  task "update:site" => "environment" do
#     current_sites.each do |site|
    site.keywords.each do |keyword|

      boards = site.active_boards
      unless keyword.code == 'kids'
        boards = boards.select{|b| keyword.match?(b)}
      end

      # prepare directory
      dir = path + keyword.code
      unless dir.exist?
        dir.mkpath
        Dir.chdir(dir) do
          system "tar xf ../skel.tar"
          system "chmod 666 *.cgi index.html subject.txt rss.rdf"
          c = keyword.code.to_s.gsub(/[^a-z0-9]/i, '')
          n = NKF.nkf('-s', keyword.name.to_s.delete("'"))
          system "sed -i -e 's/###CODE###/#{c}/' ini.php"
          system "sed -i -e 's/###NAME###/#{n}/' ini.php"
        end
      end


      # write subject.txt
      file = path + keyword.code + "subject.txt"
      buf  = Ch2::Parsers::Subject.textize(boards)
      File.open(file, "w+") do |f|
        f.print NKF.nkf('-s', buf)
      end

      # write sure.cgi
      file = path + keyword.code + "sure.cgi"
      buf  = boards.map{|b|
        "%s<>%s<>%d<>%d<>%d<>\n" % [b.code, b.name, b.count, 0, 0]
      }.join
      File.open(file, "w+") do |f|
        f.print NKF.nkf('-s', buf)
      end

      # update top page
      url = "%s/%s/top.php" % [base_url, keyword.code]
      system "wget -q -O - '#{url}' > /dev/null"
    end
  end


  ######################################################################
  ### Cache

  task "expire:cache" do
    require 'fileutils'
    %w( board board.html image/board image/popular image/tag image/show image.html index.html page ).each do |file|
      path = (Pathname(RAILS_ROOT) + "public" + file).cleanpath
      FileUtils.rm_rf path.to_s
    end
  end

  task "expire:tmp" do
    Rake::Task["tmp:cache:clear"].invoke
  end

  task "expire" do
    Rake::Task["2ch:expire:cache"].invoke
    Rake::Task["2ch:expire:tmp"].invoke
  end

  ######################################################################
  ### Composite

  desc "test all"
  task "test" do
    Rake::Task["2ch:test:openuri:lib"].invoke
  end

  desc "update all"
  task "update" do
    Rake::Task["2ch:update:data"].invoke
#    Rake::Task["2ch:update:site"].invoke
    Rake::Task["2ch:update:image"].invoke
    Rake::Task["2ch:expire"].invoke
    Rake::Task["2ch:503:update"].invoke
  end

  task "upgrade:directory" do
    Dir["dat/*/*"].each do |board|
      Dir.chdir(board) do
        Dir["*.dat"].each do |dat|
          dir = dat[0..3]
          Dir.mkdir(dir) unless File.directory?(dir)
          FileUtils.mv dat, "#{dir}/#{dat}"
        end
      end
    end
  end

  task "upgrade:image" => "environment" do
    Dir.chdir("images") do
      Ch2::Image::Fetched.find(:all).each do |image|
        next unless image.old_path.exist?
        src = image.old_path
        dst = image.path
        FileUtils.mv src, dst
      end
    end
  end

  task "503:update" do
    Dir.chdir("public/errors") do
      system("thor error:change 503 end")
    end
  end
end


