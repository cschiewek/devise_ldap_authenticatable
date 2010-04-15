Devise::Schema.class_eval do

    # Creates email
    #
    # == Options
    # * :null - When true, allow columns to be null.
    def imapable(options={})
      null = options[:null] || false

      apply_schema :email, String, :null => null
    end

end