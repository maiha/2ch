record = Ch2::Site.new
record[:id]         = 1
record[:name]       = "狼"
record[:code]       = "morningcoffee"
record[:host]       = "ex23.2ch.net"
record[:created_at] = 'Thu Aug 23 19:20:41 +0900 2007'
record[:updated_at] = 'Tue Sep 04 12:53:28 +0900 2007'
record.live_update  = true
record.save!
