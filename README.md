# README

Send your daily PV output to Slack. This app sends you a daily Slack message with your PV
output of the previous day and compared to the day before.

The message looks like:
> Hi Martijn, yesterday your Solar Panels generated 26.98 Thousand kWh. That's a +877% difference

You can run this app yourself as well:
- Deploy this app to Heroku
- Set config vars:
  - SOLAREDGE_KEY (Your SolarEdge API Key)
  - SOLAREDGE_SITE (Your SolarEdge site ID)
  - SLACK_WEBHOOK (Slack webhook key)
- Add the Heroku scheduler add-on
- Configure the Heroku scheduler add-on to run the following rake task every day: `rake notify_slack`

Based on:
- SolarEdge API: https://www.solaredge.com/sites/default/files/se_monitoring_api.pdf
- SolarEdge gem: https://github.com/martijnrusschen/solaredge
- Slack notifier: https://github.com/stevenosloan/slack-notifier
