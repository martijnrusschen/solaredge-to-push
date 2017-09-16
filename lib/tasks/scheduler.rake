require 'solar_collector'

desc "This task is called by the Heroku scheduler add-on"
task :notify_slack => :environment do
  SolarCollector.new.post_to_slack
end
