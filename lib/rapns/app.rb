module Rapns
  class App < ActiveRecord::Base
    self.table_name = 'rapns_apps'

    if Rapns.attr_accessible_available?
      attr_accessible :name, :environment, :certificate, :password, :connections, :auth_key, :daemon_id
    end

    has_many :notifications, :class_name => 'Rapns::Notification'
    belongs_to :job, :class_name => 'Rapns::Job'

    validates :name, :presence => true, :uniqueness => { :scope => [:type, :environment] }
    validates_numericality_of :connections, :greater_than => 0, :only_integer => true

    validate :certificate_has_matching_private_key

    scope :for_daemon_id, lambda { |daemon_id|
      where(daemon_id: daemon_id) 
    }

    private

    def certificate_has_matching_private_key
      result = false
      if certificate.present?
        cert = Rapns.config.encryptor_key.present? ? certificate.decrypt : certificate
        pass = Rapns.config.encryptor_key.present? ? password.decrypt : password
        x509 = OpenSSL::X509::Certificate.new(cert) rescue nil
        pkey = OpenSSL::PKey::RSA.new(cert, pass) rescue nil
        result = !x509.nil? && !pkey.nil?
        unless result
          errors.add :certificate, 'Certificate value must contain a certificate and a private key.'
        end
      end
      result
    end
  end
end
