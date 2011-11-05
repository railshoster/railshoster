h1. RailsHoster Deployment Suite

INTRDUCTON TEXT. TO BE DONE.

h2. Requirements

This is what you need on your client to run the RailsHoster gem to deploy your app:

* Ruby
* Ruby gems
* Shell (e.g. Bash)
* SSH Shell
* Git

h2. Installation

    gem install railshoster

h2. Usage
 
Simply go to your project's git folder and invoke the following command to initialize your app and *make it deployment ready*.

    railshoster init -a 'your application token' .

Regarding to your *application token* please refer to your account information you have received after signing up at [RailsHoster.com](http://www.railshoster.com/).

You can then either use *capistrano* to deploy or invoke

    railshoster deploy

It's as easy as this. Refer to the RailsHoster.com Support if any problems raise. We are happy to help you.

h2. Debug

In order to receive full stack traces when exceptions occure just pass a environment variable like this

    RAILSHOSTER_DEV=1 railshoster 