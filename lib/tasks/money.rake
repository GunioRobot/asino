namespace :money do
  
  task :get => :environment do
    accounts = Account.find(:all)
    puts "Found #{accounts.size} accounts"
    accounts.each do |account|
      account.import_from_feed
    end
  end

  task :monthreports => :environment do
    Monthreport.destroy_all
    items = Item.find(:all)
    puts "updating #{items.size} items"
    items.each do |item|
      puts item.id
      item.save
    end
  end
end