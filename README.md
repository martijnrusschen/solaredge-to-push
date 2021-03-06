# README

Send your daily PV output to Slack. This app sends you a daily Slack message with your PV
output of the previous day and compared to the day before.

The message looks like:
![Example message](https://user-images.githubusercontent.com/1412392/31050767-18956ba2-a60a-11e7-85d2-e717d222b5ae.png)


You can run this app yourself as well:
- Deploy this app to Heroku
- Set config vars:
  - SOLAREDGE_KEY (Your SolarEdge API Key)
  - SOLAREDGE_SITE (Your SolarEdge site ID)
  - SLACK_WEBHOOK (Slack webhook key)
  - CHANNEL (Slack channel you want to post the message in)
- Add the Heroku scheduler add-on
- Configure the Heroku scheduler add-on to run the following rake task every day:
  `rake daily_post` or `rake weekly_post`

## Setting up Triggi Push notifications

To send push notifications about your daily output, I used a service called Triggi.
This service allows you to easily connect multiple APIs to each other. I used the
Triggi Connector to send a push notification to my phone.

### How to set up:
- Configure the Heroku scheduler add-on to run the following rake task every day:
  `rake daily_push_notification`
- Download the Triggi app in the appstore and create an account
- Go to https://triggi.com/connect/ and follow the steps to create a connector
- Set config var: TRIGGI_CONNECTOR (This is the private part of the Triggi Connector URL)
- Now, go to the Triggi app and create a new Trigg:
  - When: "Connector" is triggered
  - Then: Send push notification. As part of the push message you need to pass in the variable "passed value"
  - Save Trigg

Based on:
- SolarEdge API: https://www.solaredge.com/sites/default/files/se_monitoring_api.pdf
- SolarEdge gem: https://github.com/martijnrusschen/solaredge
- Slack notifier: https://github.com/stevenosloan/slack-notifier
