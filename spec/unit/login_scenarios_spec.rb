require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Login scenarios' do
  def mocked_ldap_authenticatable_strategy(email:, password:)
    mapping = double("Devise::Mapping")
    mapping_to = User
    authentication_hash = { email: email }

    authenticatable = Devise::Strategies::LdapAuthenticatable.new(nil)
    allow(authenticatable).to receive(:authentication_hash).and_return(authentication_hash)
    allow(authenticatable).to receive(:password).and_return(password)
    allow(authenticatable).to receive(:mapping).and_return(mapping)
    allow(mapping).to receive(:to).and_return(mapping_to)

    allow_any_instance_of(Devise::LDAP::Connection).to receive(:email_auth_domain).and_return('cg.nl')
    authenticatable
  end

  context 'when the email is a known user' do
    context 'and the mail domain is cg.nl' do
      context 'and the password is confirmed by ldap' do
        it 'is a valid login' do
          email = 'test@cg.nl'
          password = 'test1234'

          FactoryGirl.create(:user, email: email, password: password)
          authenticatable = mocked_ldap_authenticatable_strategy(email: email, password: password)

          # Expect to check authentication in LDAP
          expect_any_instance_of(Devise::LDAP::Connection).to receive(:authenticated?).and_return(true)

          # User is authenticated by LDAP
          expect(authenticatable).to receive(:remember_me)
          expect(authenticatable).to receive(:success!)

          authenticatable.authenticate!
        end
      end

      context 'and the password is denied by ldap' do
        it 'is not a valid login' do
          email = 'test@cg.nl'
          password = 'test1234'

          FactoryGirl.create(:user, email: email, password: password)
          authenticatable = mocked_ldap_authenticatable_strategy(email: email, password: 'foo')

          # Expect to check authentication in LDAP
          expect_any_instance_of(Devise::LDAP::Connection).to receive(:authenticated?).and_return(false)

          # User is not authenticated by LDAP
          expect(authenticatable).not_to receive(:remember_me)
          expect(authenticatable).not_to receive(:success!)

          authenticatable.authenticate!
        end
      end
    end

    context 'and the mail domain is not cg.nl' do
      context 'and the password is correct' do
        it 'is a valid login' do
          email = 'test@example.com'
          password = 'test1234'

          FactoryGirl.create(:user, email: email, password: password)
          authenticatable = mocked_ldap_authenticatable_strategy(email: email, password: password)

          # Don't authenticate through LDAP
          expect_any_instance_of(Devise::LDAP::Connection).not_to receive(:authenticated?)

          # User is not authenticated by LDAP
          expect(authenticatable).not_to receive(:remember_me)
          expect(authenticatable).not_to receive(:success!)

          authenticatable.authenticate!
        end
      end

      context 'and the password is incorrect' do
        it 'is not a valid login' do
          email = 'test@example.com'
          password = 'test1234'

          FactoryGirl.create(:user, email: email, password: password)
          authenticatable = mocked_ldap_authenticatable_strategy(email: email, password: 'foo')

          # Don't authenticate through LDAP
          expect_any_instance_of(Devise::LDAP::Connection).not_to receive(:authenticated?)

          # User is not authenticated by LDAP
          expect(authenticatable).not_to receive(:remember_me)
          expect(authenticatable).not_to receive(:success!)

          authenticatable.authenticate!
        end
      end
    end
  end

  context 'when the email is not a known user' do
    context 'and the mail domain is cg.nl' do
      it 'is not a valid login' do
        authenticatable = mocked_ldap_authenticatable_strategy(email: 'test@cg.nl', password: 'foo')

        # Authenticate through LDAP
        expect_any_instance_of(Devise::LDAP::Connection).to receive(:authenticated?).and_return(false)

        # User is not authenticated by LDAP
        expect(authenticatable).not_to receive(:remember_me)
        expect(authenticatable).not_to receive(:success!)

        authenticatable.authenticate!
      end
    end

    context 'and the mail domain is not cg.nl' do
      it 'is not a valid login' do
        ::Devise.ldap_create_user = true

        authenticatable = mocked_ldap_authenticatable_strategy(email: 'test@example.com', password: 'foo')

        # Don't authenticate through LDAP
        expect_any_instance_of(Devise::LDAP::Connection).not_to receive(:authenticated?)

        # User is not authenticated by LDAP
        expect(authenticatable).not_to receive(:remember_me)
        expect(authenticatable).not_to receive(:success!)

        expect { authenticatable.authenticate! }.not_to raise_error
      end
    end
  end
end
