# encoding: utf-8
require 'devise'

require 'devise_imapable/schema'
require 'devise_imapable/imap_adapter'
require 'devise_imapable/routes'

module Devise
  # imap server address for authentication.
  mattr_accessor :imap_server
  @@imap_server = nil

  # default email suffix
  mattr_accessor :default_email_suffix
  @@default_email_suffix = nil
end

# Add +:imapable+ strategy to defaults.
#
Devise.add_module(:imapable,
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_imapable/model',
                  :routes => :imapable)
