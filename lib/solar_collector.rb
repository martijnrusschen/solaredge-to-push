include ActionView::Helpers::NumberHelper

class SolarCollector
  def post_to_slack
    notifier.ping "Hi Martijn, yesterday your Solar Panels generated #{human_power_yesterday} kWh. That's a #{diffenrence_between_days} difference", channel: '#random'
  end

  private

  def client
    SolarEdge::Client.new(ENV['SOLAREDGE_KEY'])
  end

  def site
    ENV['SOLAREDGE_SITE']
  end

  def notifier
    Slack::Notifier.new "https://hooks.slack.com/services/#{ENV['SLACK_WEBHOOK']}"
  end

  def fetch_data
    SolarEdge::Site.new(client, site).energy(resolution: :day, start_date: Time.now-2.days, end_date: Time.now-1.day)
  end

  def power_yesterday
    fetch_data.pluck(:value).last
  end

  def human_power_yesterday
    number_to_human(power_yesterday, precision: 4)
  end

  def power_2_days_ago
    fetch_data.pluck(:value).first
  end

  def diffenrence_between_days
    difference_in_percentage(power_2_days_ago, power_yesterday)
  end

  def difference_in_percentage(old, new)
    return ' +0%' if old.zero? && new.zero?

    if new.zero?
      difference = -100
    elsif old.zero?
      return ""
    else
      growth_in_percentage = (new.to_f / old.to_f) * 100
      difference = growth_in_percentage - 100
      difference = difference.round
    end

    if difference >= 0
      " +#{difference}%"
    else
      " #{difference}%"
    end
  end
end
