require 'openssl'
require 'base64'
require 'digest'

module Newebpay
	module NewebpayHelper

		def self.encrypt_data(data)
			config = Newebpay.config
			encrypt config.hash_key, config.hash_iv, data
		end

		def self.encrypt_merchant_data(data)
			config = Newebpay.merchant_config
			encrypt config.hash_key, config.hash_iv, data
		end

		def self.encrypt(key, iv, data)
			cipher = OpenSSL::Cipher::AES256.new(:CBC)
			cipher.encrypt
			cipher.padding = 0
			cipher.key = key
			cipher.iv = iv
			padding_data = add_padding(data)
			encrypted = cipher.update(padding_data) + cipher.final
			encrypted.unpack('H*').first
		end

		def self.add_padding(data, block_size=32)
			pad = block_size - (data.length % block_size)
			data + (pad.chr * pad)
		end

		def self.decrypt_merchant_data(encrypted_data)
			config = Newebpay.merchant_config
			decrypt config.hash_key, config.hash_iv, encrypted_data
		end

		def self.decrypt_data(encrypted_data)
			config = Newebpay.config
			decrypt config.hash_key, config.hash_iv, encrypted_data
		end

		def self.decrypt(key, iv, encrypted_data)
			encrypted_data = [encrypted_data].pack('H*')
			decipher = OpenSSL::Cipher::AES256.new(:CBC)
			decipher.decrypt
			decipher.padding = 0
			decipher.key = key
			decipher.iv = iv
			data = decipher.update(encrypted_data) + decipher.final
			strippadding data
		end

		def self.sha256_encode_trade_info(trade_info)
			config = Newebpay.config
			sha256_encode config.hash_key, config.hash_iv, trade_info
		end
		#to do 加密方式混亂，待整合與重新命名
		def self.create_check_value(check_string)
			config = Newebpay.config
			encode_string = "IV=#{config.hash_iv}&#{check_string}&Key=#{config.hash_key}"
			Digest::SHA256.hexdigest(encode_string).upcase
		end
		def self.create_check_code(check_string)
			config = Newebpay.config
			encode_string = "HashIV=#{config.hash_iv}&#{check_string}&HashKey=#{config.hash_key}"
			Digest::SHA256.hexdigest(encode_string).upcase
		end
		def self.sha256_encode(key, iv, trade_info, hash_iv_first = false)
			if hash_iv_first
				encode_string = "HashIV=#{iv}&#{trade_info}&HashKey=#{key}"
			else
				encode_string = "HashKey=#{key}&#{trade_info}&HashIV=#{iv}"
			end
			Digest::SHA256.hexdigest(encode_string).upcase
		end

		def self.strippadding(data)
			slast = data[-1].ord
			slastc = slast.chr
			padding_index = /#{slastc}{#{slast}}/ =~ data
			if padding_index != nil
				data[0, padding_index]
			else
				false
			end
		end
	end
end