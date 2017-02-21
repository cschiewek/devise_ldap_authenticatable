module Devise
  module LDAP
    class AttributeMapper

      DEFAULT_MAPPING = { email: 'mail',
                          password: 'userPassword',
                          firstname: 'givenName',
                          lastname: 'sn'
      }


      def initialize(status, obj, mapping = DEFAULT_MAPPING)
        @status = status
        @obj = obj
        @mapping = mapping
      end

      def get_attributes
        @obj.attributes.reject{ |p| !(@mapping.include?(p.to_sym) && (@obj.changed.include?(p) || @status == :new))  }
      end

      def get_ldap_attribute(key)
        @mapping[key]
      end

    end
  end
end