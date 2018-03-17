require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Connection' do
  it 'accepts a proc for ldap_config' do
    ::Devise.ldap_config = Proc.new() {{
      'host' => 'localhost',
      'port' => 3389,
      'base' => 'ou=testbase,dc=test,dc=com',
      'attribute' => 'cn',
    }}
    connection = Devise::LDAP::Connection.new()
    expect(connection.ldap.base).to eq('ou=testbase,dc=test,dc=com')
  end

  it 'allows encryption options to be set in ldap_config' do
    ::Devise.ldap_config = Proc.new() {{
      'host' => 'localhost',
      'port' => 3389,
      'base' => 'ou=testbase,dc=test,dc=com',
      'attribute' => 'cn',
      'encryption' => {
        :method => :simple_tls,
        :tls_options => OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
      }
    }}
    connection = Devise::LDAP::Connection.new()
    expect(connection.ldap.instance_variable_get(:@encryption)).to eq({
      :method => :simple_tls,
      :tls_options => OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
    })
  end

  class TestOpResult
    attr_accessor :error_message
  end

  describe '#expired_valid_credentials?' do
    let(:conn) { double(Net::LDAP).as_null_object }
    let(:error) { }
    let(:is_authed) { false }
    before do
      expect(Net::LDAP).to receive(:new).and_return(conn)
      allow(conn).to receive(:get_operation_result).and_return(TestOpResult.new.tap{|r| r.error_message = error})
      allow_any_instance_of(Devise::LDAP::Connection).to receive(:authenticated?).and_return(is_authed)
      allow_any_instance_of(Devise::LDAP::Connection).to receive(:dn).and_return('any dn')
      expect(DeviseLdapAuthenticatable::Logger).to receive(:send).with('Authorizing user any dn')
    end
    subject do
      Devise::LDAP::Connection.new.expired_valid_credentials?
    end

    context do
      let(:error) { 'THIS PART CAN BE ANYTHING AcceptSecurityContext error, data 773 SO CAN THIS' }
      it 'is true when expired credential error is returned and not already authenticated' do
        expect(subject).to be true
      end
    end

    context do
      it 'is false when expired credential error is not returned and not already authenticated' do
        expect(subject).to be false
      end
    end

    context do
      let(:is_authed) { true }
      it 'is false when expired credential error is not returned and already authenticated' do
        expect(subject).to be false
      end
    end
  end

  describe '#authorized?' do
    let(:conn) { double(Net::LDAP).as_null_object }
    let(:error) { }
    let(:log_message) { }
    let(:is_authed) { false }
    before do
      expect(Net::LDAP).to receive(:new).and_return(conn)
      allow(conn).to receive(:get_operation_result).and_return(TestOpResult.new.tap{|r| r.error_message = error})
      allow_any_instance_of(Devise::LDAP::Connection).to receive(:authenticated?).and_return(is_authed)
      allow_any_instance_of(Devise::LDAP::Connection).to receive(:dn).and_return('any dn')
      expect(DeviseLdapAuthenticatable::Logger).to receive(:send).with('Authorizing user any dn')
    end
    subject do
      Devise::LDAP::Connection.new.authorized?
    end
    context do
      before { expect(DeviseLdapAuthenticatable::Logger).to receive(:send).with(log_message) }

      context do
        let(:error) { 'THIS PART CAN BE ANYTHING AcceptSecurityContext error, data 52e SO CAN THIS' }
        let(:log_message) { 'Not authorized because of invalid credentials.' }
        it 'is false when credential error is returned' do
          expect(subject).to be false
        end
      end
      context do
        let(:error) { 'THIS PART CAN BE ANYTHING AcceptSecurityContext error, data 773 SO CAN THIS' }
        let(:log_message) { 'Not authorized because of expired credentials.' }
        it 'is false when expired error is returned' do
          expect(subject).to be false
        end
      end
      context do
        let(:error) { 'any error' }
        let(:log_message) { 'Not authorized because not authenticated.' }
        it 'is false when any other error is returned' do
          expect(subject).to be false
        end
      end
    end

    context do
      let(:is_authed) { true }
      it 'is true when already authenticated' do
        expect(subject).to be true
      end
    end
  end
end
