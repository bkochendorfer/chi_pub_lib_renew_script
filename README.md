Chicago Public Library Renewal Script
=====================================

Description
-----------

Script to easily allow you to renew your books at Chicago Public Library.
You can renew up to three times before you have to return or renew on site.

I keep this running as a cronjob and don't have to think about my due date.

Example Crontab
---------------

Runs at 10:30 am every day

```
30 10 * * * ~/bin/renew.rb
```
