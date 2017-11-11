include OpenSSLCookbook::Helpers

property :name,             String, name_property: true
property :owner,            String
property :group,            String
property :expire,           Integer
property :mode,             [Integer, String]
property :org,              String, required: true
property :org_unit,         String, required: true
property :country,          String, required: true
property :common_name,      String, required: true
property :subject_alt_name, Array, default: []
property :key_file,         String
property :key_pass,         String
property :key_length,       equal_to: [1024, 2048, 4096, 8192], default: 2048

action :create do
  unless ::File.exist? new_resource.name
    converge_by("Create #{@new_resource}") do
      create_keys
      cert_content = cert.to_pem
      key_content = key.to_pem

      file new_resource.name do
        action :create_if_missing
        mode new_resource.mode
        owner new_resource.owner
        group new_resource.group
        sensitive true
        content cert_content
      end

      file new_resource.key_file do
        action :create_if_missing
        mode new_resource.mode
        owner new_resource.owner
        group new_resource.group
        sensitive true
        content key_content
      end
    end
  end
end

action_class do
  def generate_key_file
    unless new_resource.key_file
      path, file = ::File.split(new_resource.name)
      filename = ::File.basename(file, ::File.extname(file))
      new_resource.key_file path + '/' + filename + '.key'
    end
    new_resource.key_file
  end

  def key
    @key ||= if key_file_valid?(generate_key_file, new_resource.key_pass)
               OpenSSL::PKey::RSA.new ::File.read(generate_key_file), new_resource.key_pass
             else
               OpenSSL::PKey::RSA.new(new_resource.key_length)
             end
    @key
  end

  def cert
    @cert ||= OpenSSL::X509::Certificate.new
  end

  def gen_cert
    cert
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + (new_resource.expire.to_i * 24 * 60 * 60)
    cert.public_key = key.public_key
    cert.serial = 0x0
    cert.version = 2
  end

  def subject
    @subject ||= '/C=' + new_resource.country +
                 '/O=' + new_resource.org +
                 '/OU=' + new_resource.org_unit +
                 '/CN=' + new_resource.common_name
  end

  def extensions
    exts = []
    exts << @ef.create_extension('basicConstraints', 'CA:TRUE', true)
    exts << @ef.create_extension('subjectKeyIdentifier', 'hash')

    unless new_resource.subject_alt_name.empty?
      san = {}
      counters = {}
      new_resource.subject_alt_name.each do |an|
        kind, value = an.split(':', 2)
        counters[kind] ||= 0
        counters[kind] += 1
        san["#{kind}.#{counters[kind]}"] = value
      end
      @ef.config['alt_names'] = san
      exts << @ef.create_extension('subjectAltName', '@alt_names')
    end

    exts
  end

  def create_keys
    gen_cert
    @ef ||= OpenSSL::X509::ExtensionFactory.new
    @ef.subject_certificate = cert
    @ef.issuer_certificate = cert
    @ef.config = OpenSSL::Config.load(OpenSSL::Config::DEFAULT_CONFIG_FILE)

    cert.extensions = extensions
    cert.add_extension @ef.create_extension('authorityKeyIdentifier',
                                           'keyid:always,issuer:always')
    cert.sign key, OpenSSL::Digest::SHA256.new
  end
end
