class Providers
  class Slack
    CHANNEL = ENV['CHANNEL']

    def post_to_slack(new_value, average)
      @new_value = new_value
      @average = average

      notifier.ping message, channel: CHANNEL, username: "RusPower", attachments: attachments
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
              title: 'Yesterday',
              value: @end_date.strftime("%d/%m/%Y"),
              short: true,
            },
            {
              title: "Production",
              value: "#{value_to_human(@new_value)}kWh",
              short: true,
            },
            {
              title: 'The average of the last 30 days',
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

    def notifier
      Slack::Notifier.new "https://hooks.slack.com/services/#{ENV['SLACK_WEBHOOK']}"
    end
  end
end
