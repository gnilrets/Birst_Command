module Birst_Command
  module Password
    extend self

    def generate_keys(verbose: false)
      iv    = ENV['BIRST_COMMAND_IV']   || SecureRandom.base64
      key   = ENV['BIRST_COMMAND_KEY']  || SecureRandom.base64(32)
      salt  = ENV['BIRST_COMMAND_SALT'] || SecureRandom.base64

      if verbose
        puts <<-EOF.unindent
        Set these keys as environment variables 
         - Do not lose them or you will have to regenerate your password.
         - Keep them secure, your password is compromised if these keys are compromised.
         - Remove them as environment variables to generate new ones
        BIRST_COMMAND_IV="#{iv}"
        BIRST_COMMAND_KEY="#{key}"
        BIRST_COMMAND_SALT="#{salt}"
        EOF
      end
      
      ENV['BIRST_COMMAND_IV']   = iv
      ENV['BIRST_COMMAND_KEY']  = key
      ENV['BIRST_COMMAND_SALT'] = salt
    end

    # Generate a new cipher for encryption or decryption
    def create_cipher(mode)
      iv   = ENV['BIRST_COMMAND_IV']   || SecureRandom.base64
      key  = ENV['BIRST_COMMAND_KEY']  || SecureRandom.base64(32)
      salt = ENV['BIRST_COMMAND_SALT'] || SecureRandom.base64

      cipher = OpenSSL::Cipher.new 'AES-128-CBC'
      cipher.send(mode)
      cipher.iv = iv

      digest = OpenSSL::Digest::SHA256.new
      key_len = cipher.key_len
      iter = 20000
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac(key, salt, iter, key_len, digest)
      cipher
    end


    # Returns a base64-obfuscated password to be stored in the config.json file
    def encrypt(pwd)
      cipher = create_cipher(:encrypt)

      encrypted = cipher.update pwd
      encrypted << cipher.final

      Base64.encode64(encrypted).chomp
    end


    # Returns a plaintext password
    def decrypt(encrypted_pwd)
      cipher = create_cipher(:decrypt)

      decrypted = cipher.update Base64.decode64(encrypted_pwd)
      decrypted << cipher.final

      decrypted
    end
  end
end
