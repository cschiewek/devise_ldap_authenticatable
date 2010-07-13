Devise LDAP Authenticatable
===========================

Devise LDAP Authenticatable is a LDAP based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use LDAP, this plugin is for you.

For a screencast with an example application, please visit: [http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html](http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html)

Requirements
------------

- An LDAP server (tested on OpenLDAP)
- Rails 3.0.0.beta4
- Devise 1.1.rc2
- ruby-net-ldap 0.0.4

Installation
------------

**_Please Note_**

This will *only* work for Rails 3 applications.

In the Gemfile for your application:

    gem "devise", "1.1.rc2"
    gem "devise_ldap_authenticatable", "0.3.4"

For latest version, use the git repository instead

    gem "devise_ldap_authenticatable", :git => "git://github.com/cschiewek/devise_ldap_authenticatable.git", :branch => "rails3"

Setup
-----

Run the rails generator

    rails generate devise_ldap_authenticatable:install

This will install the sample.yml, update the devise.rb initializer, and update your user model. There are some options you can pass to it:

    [--user-model=USER_MODEL]  # Model to update
                               # Default: user
    [--update-model]           # Update model to change from database_authenticatable to ldap_authenticatable
                               # Default: true


Usage
-----

Devise LDAP Authenticatable works in replacement of Database Authenticatable

**_Please Note_**

This devise plugin has not been tested with DatabaseAuthenticatable enabled at the same time. This is meant as a drop in replacement for DatabaseAuthenticatable allowing for a semi single sign on approach.


Configuration
-------------

In initializer  `config/initializers/devise.rb` :

* ldap\_create\_user
	* If set to true, all valid LDAP users will be allowed to login and an appropriate user record will be created.
      If set to false, you will have to create the user record before they will be allowed to login.

* ldap\_config
	* Where to find the LDAP config file. Commented out to use the default, change if needed.

* ldap\_update\_password
  * When doing password resets, if true will update the LDAP server. Requires admin password in the ldap.yml

Testing
-------

This has been tested using the following setup:

* Mac OSX 10.6
* OpenLDAP 2.4.11
* REE 1.8.7 (2010.02)

All unit and functional tests are part of a sample rails application under test/rails_app and requires a working LDAP sever. There are config files and setup instructions under test/ldap

References
----------

* [Original Plugin](http://github.com/cschiewek/devise_ldap_authenticatable)
* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)


TODO
----

View on [Pivotal Tracker](http://www.pivotaltracker.com/projects/97318).

Released under the MIT license

Copyright (c) 2010 Curtis Schiewek, Daniel McNevin

