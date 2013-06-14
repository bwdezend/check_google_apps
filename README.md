check_google_apps
=================

A Nagios plugin to check the status of Google Apps for Education, Business, and Domain.

This plugin scrapes the Google Apps Status dashboard JSON object at http://www.google.com/appsstatus/json/en, unpacks it and lets you check to see if there is currently a reported problem with a Google Apps service. The service check is set to only return OK or WARNING, as there is almost nothing a user of Google Apps can do to fix the issue.