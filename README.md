Devise LDAP Authenticatable
===========================

Devise LDAP Authenticatable is a LDAP based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use LDAP, this plugin is for you.

For a screencast with an example application, please visit: [http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html](http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html)

Requirements
------------

- An LDAP server (tested on OpenLDAP)
- Rails 3.0.0.beta4

These gems are dependencies of the gem:

- Devise 1.1.rc2
- net-ldap 0.1.1

Installation
------------

**_Please Note_**

This will *only* work for Rails 3 applications.

In the Gemfile for your application:

    gem "devise", "1.1.rc2"
    gem "devise_ldap_authenticatable", "0.4.0"
    
To get the latest version, pull directly from github instead of the gem:

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
    [--add-rescue]             # Update Application Controller with resuce_from for DeviseLdapAuthenticatable::LdapException
                               # Default: true



Usage
-----

Devise LDAP Authenticatable works in replacement of Database Authenticatable

**_Please Note_**

This devise plugin has not been tested with DatabaseAuthenticatable enabled at the same time. This is meant as a drop in replacement for DatabaseAuthenticatable allowing for a semi single sign on approach.

The field that is used for logins is the first key that's configured in the `config/devise.rb` file under `config.authentication_keys`, which by default is email. For help changing this, please see the [Railscast](http://railscasts.com/episodes/210-customizing-devise) that goes through how to customize Devise.

Configuration
-------------

In initializer  `config/initializers/devise.rb` :

* ldap\_logger _(default: true)_
  * If set to true, will log LDAP queries to the Rails logger.

* ldap\_create\_user _(default: false)_
	* If set to true, all valid LDAP users will be allowed to login and an appropriate user record will be created.
      If set to false, you will have to create the user record before they will be allowed to login.

* ldap\_config _(default: #{Rails.root}/config/ldap.yml)_
	* Where to find the LDAP config file. Commented out to use the default, change if needed.

* ldap\_update\_password _(default: true)_
  * When doing password resets, if true will update the LDAP server. Requires admin password in the ldap.yml

* ldap\_check\_group_membership _(default: false)_
  * When set to true, the user trying to login will be checked to make sure they are in all of groups specified in the ldap.yml file.


* ldap\_check\_attributes _(default: false)_
  * When set to true, the user trying to login will be checked to make sure they have all of the attributes in the ldap.yml file.

* ldap\_use\_admin\_to\_bind _(default: false)_
  * When set to true, the admin user will be used to bind to the LDAP server during authentication.

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

