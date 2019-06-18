module Newebpay
	
	class BankCodes
		@@bank_codes = {
			CathayBK: "國泰世華銀行",
			CTBC: "中國信託銀行",
			Esun: "玉山銀行",
			HNCB: "華南銀行",
			NCCC: "聯合信用卡",
			Taishin: "台新銀行"
		}

		def self.bank_codes
			@@bank_codes
		end

		# def self.get_error_message code
		# 	@error_code[code]
		# end
	end
end