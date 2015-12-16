require 'date'

module OpenSSL
  def self.gen_account_key
    system 'openssl genrsa 4096 > /var/lib/nginx-acme/account.key'
  end

  def self.gen_domain_key(domain)
    system "openssl genrsa 4096 > #{domain.key_path}"
  end

  def self.create_csr(domain)
    system "openssl req -new -sha256 -key #{domain.key_path} -subj '/CN=#{domain.name}' > #{domain.csr_path}"
  end

  def self.need_to_sign_or_renew?(domain)
    skip_conditions = NAConfig.production? &&
                      File.exist?(domain.key_path) &&
                      File.exist?(domain.chained_cert_path) &&
                      expires_in_days(domain.chained_cert_path) > 30

    !skip_conditions
  end

  def self.expires_in_days(pem)
    (expires_at(pem) - Date.today).to_i
  end

  private

  def self.expires_at(pem)
    date_str = `openssl x509 -enddate -noout -in #{pem}`.sub('notAfter=', '')
    Date.parse date_str
  end
end
