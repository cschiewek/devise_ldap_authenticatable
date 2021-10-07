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

  describe '#in_required_groups?' do
    before do
      conn = double(Net::LDAP).as_null_object
      allow(Net::LDAP).to receive(:new).and_return(conn)
    end

    let(:check_group_membership) { true }
    let(:required_groups) { %w[group1 group2] }

    let(:connection) do
      Devise::LDAP::Connection.new.tap do |c|
        allow(c).to receive(:dn).and_return('any dn')
        c.instance_variable_set(:@required_groups, required_groups)
        c.instance_variable_set(:@check_group_membership, check_group_membership)
      end
    end

    context 'required_groups is given as array of strings' do
      it 'returns true if member of all the listed group' do
        allow(connection).to receive(:in_group?).with('group1').and_return(true)
        allow(connection).to receive(:in_group?).with('group2').and_return(false)
        expect(connection.in_required_groups?).to be(false)

        allow(connection).to receive(:in_group?).with('group1').and_return(true)
        allow(connection).to receive(:in_group?).with('group2').and_return(true)
        expect(connection.in_required_groups?).to be(true)
      end
    end

    context 'required_groups is given as array of arrays' do
      let(:required_groups) do
        [
          %w[member group1 group2]
        ]
      end

      it 'returns true if member of any required group' do
        allow(connection).to receive(:in_group?).with('group1', 'member').and_return(false)
        allow(connection).to receive(:in_group?).with('group2', 'member').and_return(true)
        expect(connection.in_required_groups?).to be(true)

        allow(connection).to receive(:in_group?).with('group1', 'member').and_return(true)
        allow(connection).to receive(:in_group?).with('group2', 'member').and_return(false)
        expect(connection.in_required_groups?).to be(true)

        allow(connection).to receive(:in_group?).with('group1', 'member').and_return(false)
        allow(connection).to receive(:in_group?).with('group2', 'member').and_return(false)
        expect(connection.in_required_groups?).to be(false)
      end
    end

    context 'with check_group_membership false' do
      let(:check_group_membership) { false }

      it 'returns always true' do
        expect(connection.in_required_groups?).to be(true)
      end
    end

    context 'with nil required_groups' do
      let(:required_groups) { nil }

      it 'returns always false' do
        expect(connection.in_required_groups?).to be(false)
      end
    end

    context 'with no required_groups' do
      let(:required_groups) { [] }

      it 'returns always true' do
        expect(connection.in_required_groups?).to be(true)
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
