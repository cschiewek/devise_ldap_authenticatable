Devise::Schema.class_eval do
    # Creates login
    #
    # == Options
    # * :null - When true, allow columns to be null.
    def ldap_authenticatable(options={})
      null = options[:null] || false

      apply_schema :login, String, :null => false
      apply_schema :ldap_attributes, String, :null => true
    end

end