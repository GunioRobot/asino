class Account < ActiveRecord::Base

  require 'rss/2.0'
  require 'open-uri'
  require 'date'
  require 'feed_tools'

  has_many :items, :order => 'created_at desc', :dependent => :destroy
  has_many :rulesets, :dependent => :destroy
  has_many :monthreports, :dependent => :destroy

  def import_from_feed
    RAILS_DEFAULT_LOGGER.debug "importing for #{self.title}/#{self.feed}"

    feed = FeedTools::Feed.open(self.feed)
    RAILS_DEFAULT_LOGGER.debug "feed: #{feed.inspect}"

    puts feed.title
    puts feed.link
    puts feed.description
    puts feed.items.size

    for item in feed.items
      puts item.title.split(' - ')[1]
      next if Item.exists?(:uid => item.id)
      puts "adding #{item.title.split(' - ')[1]}"
      Item.create({:uid => item.id, 
                   :created_at => item.updated.to_date,
                   :account_id => self.id,
                   :amount => item.title.split(' - ')[0].delete('.').gsub(',','.').to_f,
                   :payee => item.title.split(' - ')[1],
                   :description => item.title.split(' - ')[2]})
    end

    #self.last_update = DateTime.parse(rss.items.first.pubDate.to_s)
    #self.save
  end
end
