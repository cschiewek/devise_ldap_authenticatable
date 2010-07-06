module DeviseLdapAuthenticatable
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    class_option :user_model, :type => :string, :default => "user", :desc => "Model to update"
    class_option :update_model, :type => :boolean, :default => true, :desc => "Update model to change from database_authenticatable to ldap_authenticatable"
    
    def create_ldap_config
      copy_file "ldap.yml", "config/ldap.yml"
    end
    
    def create_default_devise_settings
      inject_into_file "config/initializers/devise.rb", default_devise_settings, :after => "Devise.setup do |config|\n"   
    end
    
    def update_user_model
      gsub_file "app/models/#{options.user_model}.rb", /:database_authenticatable/, ":ldap_authenticatable" if options.update_model?
    end
    
    private
    
    def default_devise_settings
      <<-eof
  # ==> LDAP Configuration 
  # config.ldap_create_user = false
  # config.ldap_update_password = true
  # config.ldap_config = "\#{Rails.root}/config/ldap.yml"
    
      eof
    end
    
  end
end