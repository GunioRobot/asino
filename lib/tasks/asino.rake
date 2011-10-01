namespace :asino do
  
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
      item.add_to_monthreport
    end
  end
  
  task:backup => :environment do
    unless config = YAML::load(ERB.new(IO.read(RAILS_ROOT + "/config/database.yml")).result)[RAILS_ENV]
      abort "No database is configured for the environment '#{RAILS_ENV}'"
    end

    db_out_path = File.join(RAILS_ROOT, 'db/backups', "asino_#{Time.now.strftime("%Y_%m_%d_%H_%M")}_#{RAILS_ENV}.sql")
    system "mysqldump -u #{config['username']} --password=#{config['password']} #{config['database']} > #{db_out_path}"
  end

end