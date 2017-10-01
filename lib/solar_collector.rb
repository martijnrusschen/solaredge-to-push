include ActionView::Helpers::NumberHelper

class SolarCollector
  SITE = ENV['SOLAREDGE_SITE']
  CHANNEL = ENV['CHANNEL']

  def post(resolution)
    data = fetch_data(resolution)
    notifier.ping message(resolution), channel: CHANNEL, username: "RusPower"
  end

  private

  def determine_time_series(resolution)
    case resolution
    when :day
      @start_date = Time.now-2.days
      @end_date = Time.now-1.day
    when :week
      @start_date = Time.now-2.weeks
      @end_date = Time.now-1.week
    end
  end

  def message(resolution)
    case resolution
    when :day
      "Hi Martijn, yesterday your solar panels generated #{value_to_human(@new_value)}" +
      "Wh. That's a #{difference_in_percentage(@old_value, @new_value)} difference compared to the day before."
    when :week
      "Hi Martijn, last week your solar panels generated #{value_to_human(@new_value)}" +
      "Wh. That's a #{difference_in_percentage(@old_value, @new_value)} difference compared to the week before."
    end
  end

  def fetch_data(resolution)
    determine_time_series(resolution)

    raw_data = SolarEdge::Site.new(client, SITE).energy(
      resolution: resolution,
      start_date: @start_date,
      end_date: @end_date
    )

    @old_value = raw_data.pluck(:value).first
    @new_value = raw_data.pluck(:value).last
  end

  def client
    SolarEdge::Client.new(ENV['SOLAREDGE_KEY'])
  end

  def notifier
    Slack::Notifier.new "https://hooks.slack.com/services/#{ENV['SLACK_WEBHOOK']}"
  end

  def value_to_human(value)
    number_with_delimiter(number_with_precision(value, precision: 0), precision: 4)
  end

  def difference_in_percentage(old, new)
    return '+0%' if old.zero? && new.zero?

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
      "+#{difference}%"
    else
      "#{difference}%"
    end
  end
end
