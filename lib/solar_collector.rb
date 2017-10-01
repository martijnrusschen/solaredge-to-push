include ActionView::Helpers::NumberHelper

class SolarCollector
  SITE = ENV['SOLAREDGE_SITE']
  CHANNEL = ENV['CHANNEL']

  def post(resolution)
    data = fetch_data(resolution)
    notifier.ping message(resolution), channel: CHANNEL, username: "RusPower", attachments: attachments
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
      old_value_label = 'day'
      new_value_label = 'yesterday'
    when :week
      old_value_label = 'week'
      new_value_label = 'last week'
    end

    "Hi Martijn, #{new_value_label} your solar panels generated #{value_to_human(@new_value)}" +
    "Wh. That's a #{difference_in_percentage(@old_value, @new_value)} difference compared " +
    "to the #{old_value_label} before."
  end

  def color
    if @new_value > @old_value
      'good'
    elsif @new_value < @old_value
      'danger'
    else
      '#439FE0'
    end
  end

  def attachments
    [
      {
        color: color,
        fields: [
          {
            title: 'Yesterday',
            value: @end_date.strftime("%d/%m/%Y"),
            short: true,
          },
          {
            title: "Production",
            value: "#{value_to_human(@new_value)}Wh",
            short: true,
          },
          {
            title: 'Day before',
            value: @start_date.strftime("%d/%m/%Y"),
            short: true,
          },
          {
            title: 'Production',
            value: "#{value_to_human(@old_value)}Wh",
            short: true,
          }
        ]
      }
    ]
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
