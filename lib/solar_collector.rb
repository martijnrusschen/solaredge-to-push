include ActionView::Helpers::NumberHelper
require 'httparty'

class SolarCollector
  SITE = ENV['SOLAREDGE_SITE']
  CHANNEL = ENV['CHANNEL']
  TRIGGI_CONNECTOR = ENV['TRIGGI_CONNECTOR']
  USER_TOKEN = ENV['PUSHOVER_USER_TOKEN']
  APP_TOKEN = ENV['PUSHOVER_APP_TOKEN']

  def post_to_slack
    fetch_data
    notifier.ping message, channel: CHANNEL, username: "RusPower", attachments: attachments
  end

  def send_push_notification
    fetch_data
    Pushover.notification(message: message, title: 'RusPower', user: USER_TOKEN, token: APP_TOKEN)
  end

  private

  def message
    @average_label = 'the average of the last 30 days'
    @new_value_label = 'yesterday'

    "Hi Martijn, #{@new_value_label} your solar panels generated #{value_to_human(@new_value)}" +
    "kWh. That's #{difference_in_percentage(@average, @new_value)}% #{@difference_label} compared " +
    "to #{@average_label}."
  end

  def color
    if @new_value > @average
      'good'
    elsif @new_value < @average
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
            title: @new_value_label.capitalize,
            value: @end_date.strftime("%d/%m/%Y"),
            short: true,
          },
          {
            title: "Production",
            value: "#{value_to_human(@new_value)}kWh",
            short: true,
          },
          {
            title: @average_label.capitalize,
            value: @start_date.strftime("%d/%m/%Y"),
            short: true,
          },
          {
            title: 'Production',
            value: "#{value_to_human(@average)}kWh",
            short: true,
          }
        ]
      }
    ]
  end

  def fetch_data
    @start_date = Time.now-31.days
    @end_date = Time.now-1.day

    raw_data = SolarEdge::Site.new(client, SITE).energy(
      resolution: :day,
      start_date: @start_date,
      end_date: @end_date
    )

    values = raw_data.pluck(:value)
    average = values.sum / values.size.to_f

    @average = average
    @new_value = values.last
  end

  def client
    SolarEdge::Client.new(ENV['SOLAREDGE_KEY'])
  end

  def notifier
    Slack::Notifier.new "https://hooks.slack.com/services/#{ENV['SLACK_WEBHOOK']}"
  end

  def value_to_human(value)
    value = value/1_000
    number_with_precision(value, precision: 2)
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
      @difference_label = 'higher'
    else
      @difference_label = 'lower'
    end

    difference
  end
end
