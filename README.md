blog2digest is a simple script that scrapes an RSS feed for all entries in the
previous week and sends them as a digest email.  I initially designed this
because, at the time, I was working in a highly autonomous job and my boss
wanted me to send him an email on Fridays to keep him up to date on what I had
been working on over the week.  I had trouble for the first couple weeks
remembering everything I had been working on throughout the week and so I
started a work blog to track what I worked on.  I then wrote this script to
automate the end product to my boss.

## blog2digest.ini ##
* **feed_url** - The URL of the RSS feed to scrape.
* **from_email** - The email address to use in the From field of the email.
* **to_email** - The email address to send the email to.

