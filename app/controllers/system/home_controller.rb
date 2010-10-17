class System::HomeController < ApplicationController

def backup
  
  unless config = YAML::load(ERB.new(IO.read(RAILS_ROOT + "/config/database.yml")).result)[RAILS_ENV]
    abort "No database is configured for the environment '#{RAILS_ENV}'"
  end

  @db_out_path = File.join(RAILS_ROOT, 'db/backups', "asino_#{Time.now.strftime("%Y_%m_%d_%H_%M")}_#{RAILS_ENV}.sql")
  system "mysqldump -u #{config['username']} --password=#{config['password']} #{config['database']} > #{@db_out_path}"
end

end
