require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Devise::LDAP::Adapter do
  describe '#expired_credentials?' do
    before do
      ::Devise.ldap_use_admin_to_bind = true
      expect_any_instance_of(Devise::LDAP::Connection).to receive(:expired?)
    end

    it 'can bind as the admin user' do
      expect(Devise::LDAP::Connection).to receive(:new)
        .with(hash_including(
          :login => 'test.user@test.com',
          :password => 'pass',
          :ldap_auth_username_builder => kind_of(Proc),
          :admin => true)).and_call_original

      Devise::LDAP::Adapter.expired_credentials?('test.user@test.com', 'pass')
    end
  end
end
