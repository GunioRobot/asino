# Account actually refers to a realy bank account. It holds many items.
class Account < ActiveRecord::Base

  require 'rss/2.0'
  require 'open-uri'
  require 'date'
  #require 'feed_tools'

  has_many :items, :order => 'created_at desc', :dependent => :destroy
  has_many :rulesets, :dependent => :destroy
  has_many :monthreports, :dependent => :destroy

  validates_presence_of :title, :message => "Bitte geben Sie dem Konto einen Namen!"
  validates_uniqueness_of :title, :message => "Dieser Kontoname wird bereits verwendet!"

  def import_from_feed
    feed = Feedzirra::Feed.fetch_and_parse(self.feed)
    feed.entries.each do |entry|
      puts entry.title.split(' - ')[1]
      next if Item.exists?(:uid => entry.id) # that would have been nice. but looks like the uid in the feed changes
      # so we check for duplicates by content. Not good for items that are really the same
      next if Item.exists?(:amount => entry.title.sanitize.split(' - ')[0].delete('.').gsub(',','.').to_f,
                            :created_at => entry.updated.to_date,:account_id => self.id,
                            :payee => entry.title.sanitize.split(' - ')[1],
                            :description => entry.title.sanitize.split(' - ')[2])
      puts "adding #{entry.title.split(' - ')[1]}"
      puts "    date: #{entry.updated}"
      Item.create({:uid => entry.id,
                   :created_at => entry.updated.to_date,
                   :account_id => self.id,
                   :amount => entry.title.sanitize.split(' - ')[0].delete('.').gsub(',','.').to_f,
                   :payee => entry.title.sanitize.split(' - ')[1],
                   :description => entry.title.sanitize.split(' - ')[2]})
    end
  end
end
