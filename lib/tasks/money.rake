namespace :money do
  
  task :get => :environment do
    accounts = Account.find(:all)
    puts "Found #{accounts.size} accounts"
    accounts.each do |account|
      next if account.feed.blank?
      account.import_from_feed
    end
  end

  task :monthreports => :environment do
    Monthreport.destroy_all
    items = Item.find(:all, :order => "created_at")
    puts "updating #{items.size} items"
    items.each do |item|
      #puts item.id
      item.add_to_monthreport
    end
  end

end