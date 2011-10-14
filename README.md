Devise LDAP Authenticatable
===========================

Devise LDAP Authenticatable is a LDAP based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use LDAP, this plugin is for you.

For a screencast with an example application, please visit: [http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html](http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html)

**_Please Note_**

If you are using rails 2.x then use 0.1.x series of gem, and see the rails2 branch README for instructions.

Requirements
------------

- An LDAP server (tested on OpenLDAP)
- Rails 3.0.0

These gems are dependencies of the gem:

- Devise ~> 1.4.0 
- net-ldap ~> 0.2.2

Installation
------------

**_Please Note_**

This will *only* work for Rails 3 applications.

In the Gemfile for your application:

    gem "devise", "~> 1.4"
    gem "devise_ldap_authenticatable"
    
To get the latest version, pull directly from github instead of the gem:

    gem "devise_ldap_authenticatable", :git => "git://github.com/cschiewek/devise_ldap_authenticatable.git"


Setup
-----

Run the rails generators for devise (please check the [devise](http://github.com/plataformatec/devise) documents for further instructions)

    rails generate devise:install
    rails generate devise MODEL_NAME

Run the rails generator for devise_ldap_authenticatable

    rails generate devise_ldap_authenticatable:install [options]

This will install the sample.yml, update the devise.rb initializer, and update your user model. There are some options you can pass to it:

Options:

    [--user-model=USER_MODEL]  # Model to update
                               # Default: user
    [--update-model]           # Update model to change from database_authenticatable to ldap_authenticatable
                               # Default: true
    [--add-rescue]             # Update Application Controller with resuce_from for DeviseLdapAuthenticatable::LdapException
                               # Default: true
    [--advanced]               # Add advanced config options to the devise initializer


Usage
-----

Devise LDAP Authenticatable works in replacement of Database Authenticatable

**_Please Note_**

This devise plugin has not been tested with DatabaseAuthenticatable enabled at the same time. This is meant as a drop in replacement for DatabaseAuthenticatable allowing for a semi single sign on approach.

The field that is used for logins is the first key that's configured in the `config/devise.rb` file under `config.authentication_keys`, which by default is email. For help changing this, please see the [Railscast](http://railscasts.com/episodes/210-customizing-devise) that goes through how to customize Devise.


Querying LDAP
----------------

Given that ldap\_create\_user is set to true and you are authenticating with username, you can query an LDAP server for other attributes.

in your user model:

	before_save :get_ldap_email

  def get_ldap_email
    self.email = Devise::LdapAdapter.get_ldap_param(self.username,"mail")
  end


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


Advanced Configuration
----------------------

These parameters will be added to `config/initializers/devise.rb` when you pass the `--advanced` switch to the generator:

* ldap\_auth\_username\_builder _(default: `Proc.new() {|attribute, login, ldap| "#{attribute}=#{login},#{ldap.base}" }`)_
  * You can pass a proc to the username option to explicitly specify the format that you search for a users' DN on your LDAP server.

Testing
-------

This has been tested using the following setup:

* Mac OSX 10.6
* OpenLDAP 2.4.11
* REE 1.8.7 (2010.02)

All unit and functional tests are part of a sample rails application under test/rails_app and requires a working LDAP sever.

Build / Start Instructions for Test LDAP Server
-----------------------------------------------

These instructions require the current directory context to be the `test/ldap` directory relative to the project root.

  1. To start the server, run `./run-server.sh`
  2. Add the basic structure: `ldapadd -x -h localhost -p 3389 -x -D "cn=admin,dc=test,dc=com" -w secret -f base.ldif`
    * this creates the users / passwords:
      * cn=admin,dc=test,com / secret
      * cn=example.user@test.com,ou=people,dc=test,dc=com / secret
  3. You should now be able to run the tests in test/rails_app by running: `rake`
  
  _For a LDAP server running SSL_
  
  1. To start the server, run: `./run-server.sh --ssl`
  2. Add the basic structure: `ldapadd -x -H ldaps://localhost:3389 -x -D "cn=admin,dc=test,dc=com" -w secret -f base.ldif`
    * this creates the users / passwords:
      * cn=admin,dc=test,com / secret
      * cn=example.user@test.com,ou=people,dc=test,dc=com / secret
  3. You should now be able to run the tests in test/rails_app by running: `LDAP_SSL=true rake`

**_Please Note_**

In your system LDAP config file (on OSX it's /etc/openldap/ldap.conf) make sure you have the following setting:

    TLS_REQCERT	never

This will allow requests to go to the test LDAP server without being signed by a trusted root (it uses a self-signed cert)

References
----------

* [OpenLDAP](http://www.openldap.org/)
* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)


TODO
----

View on [Pivotal Tracker](http://www.pivotaltracker.com/projects/97318).

Released under the MIT license

Copyright (c) 2010 Curtis Schiewek, Daniel McNevin

