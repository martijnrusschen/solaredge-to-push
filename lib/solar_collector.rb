require 'base'
include Base

class SolarCollector
  def post_to_slack
    message = "Hi Martijn, yesterday your solar panels generated #{human_new_value}" +
    "Wh. That's a #{difference_in_percentage(old_value, new_value)} difference compared to the day before."

    notifier.ping message, channel: '#random', username: "RusPower"
  end

  private

  def fetch_data
    SolarEdge::Site.new(client, SITE).energy(resolution: :day, start_date: Time.now-2.days, end_date: Time.now-1.day)
  end
end
