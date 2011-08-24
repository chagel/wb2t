#!/usr/bin/env ruby 
# Import RSS of Sina Weibo to Twitter status
# chagel@gmail.com

require 'rubygems'
require 'twitter'
require 'simple-rss'
require 'open-uri'

Twitter.configure do |config|
  config.consumer_key = 'YOUR DATA'
  config.consumer_secret = 'YOUR DATA'
  config.oauth_token = 'YOUR DATA'
  config.oauth_token_secret = 'YOUR DATA'
end

class Weibo2Twitter
  @@weibo_rss = "http://medcl.net/sinarss/?uname=chagel&originalimage=false&titlelimit=200"
  @@sync_time = "wb2t_st"
  @@sync_log = "wb2t.log"

  def sync
    last_sync_time = load_data
    begin 
      debug "Reading rss file: #{@@weibo_rss}"
      rss = SimpleRSS.parse(open(@@weibo_rss))
      rss.items.reverse.each_with_index do |item, index|
        if item.pubDate > last_sync_time
          debug "sync message - #{item.pubDate} - #{item.title}"
          Twitter.update "#{item.title}"
          dump_data item.pubDate
          sleep 3
        end
      end
    rescue Exception => e
      debug e.message
    end
  end

  def debug(message)
    File.open(@@sync_log, 'a') do |f|
      f.write "\n #{Time.now}: #{message}"
    end
  end

  def load_data
    if File.exists?(@@sync_time)
        Marshal.load(File.read(@@sync_time))
      else
        Time.mktime('2011')
    end
  end

  def dump_data(data)
    File.open(@@sync_time, 'w') do |f|
      f.write Marshal.dump(data)
    end
  end
end

wt = Weibo2Twitter.new
wt.sync