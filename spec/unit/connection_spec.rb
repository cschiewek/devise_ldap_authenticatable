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

  class TestOpResult
    attr_accessor :error_message
  end

  describe '#expired?' do
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
      Devise::LDAP::Connection.new.expired?
    end

    context do
      let(:error) { 'DOESNT REALLY MATTER AcceptSecurityContext error, data 773 NOPE' }
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
        let(:error) { 'COULD BE ANYTHING FROM ANYWHERE AcceptSecurityContext error, data 52e SOMETHING ELSE' }
        let(:log_message) { 'Not authorized because of invalid credentials.' }
        it 'is false when credential error is returned' do
          expect(subject).to be false
        end
      end
      context do
        let(:error) { 'IMPORTANT SECRET MESSAAGES AcceptSecurityContext error, data 773 IMPORTANT THINGS' }
        let(:log_message) { 'Not authorized because expired credentials.' }
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
