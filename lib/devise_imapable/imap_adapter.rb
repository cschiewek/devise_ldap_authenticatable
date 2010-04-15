require 'net/imap'

module Devise

  # simple adapter for imap credential checking
  # (i don't like to add stuff like this directly to the model)
  module ImapAdapter

    def self.valid_credentials?(username, password)
      imap = Net::IMAP.new(::Devise.imap_server)
      imap.authenticate("cram-md5", username, password)
      true
    rescue Net::IMAP::ResponseError => e
      false
    ensure
      imap.disconnect
    end

  end

end