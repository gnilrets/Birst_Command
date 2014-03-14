module Birst_Command
  module Obfuscate
    extend self

    @crypt_pwd = "BirstIsAwesome"
    @salt = "31415927"
    @cypher = "AES-128-CBC"

    def obfuscate(pwd)
      # Returns a base64-obfuscated password to be stored in the config.json file
      encrypter = OpenSSL::Cipher::Cipher.new @cypher
      encrypter.encrypt
      encrypter.pkcs5_keyivgen @crypt_pwd, @salt

      encrypted = encrypter.update pwd
      encrypted << encrypter.final

      Base64.encode64(encrypted).chomp
    end


    def deobfuscate(obfuscated_pwd)
      # Returns a plaintext password
      decrypter = OpenSSL::Cipher::Cipher.new @cypher
      decrypter.decrypt
      decrypter.pkcs5_keyivgen @crypt_pwd, @salt

      plain = decrypter.update Base64.decode64(obfuscated_pwd)
      plain << decrypter.final

      plain
    end

  end
end
