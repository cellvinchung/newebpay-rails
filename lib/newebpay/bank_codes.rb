module Newebpay
	class BankCodes
		def self.bank_codes
			@bank_codes ||= {
				CathayBK: "國泰世華銀行",
				CTBC: "中國信託銀行",
				Esun: "玉山銀行",
				HNCB: "華南銀行",
				NCCC: "聯合信用卡中心",
				Taishin: "台新銀行",
				Citibank: '花旗銀行',
				UBOT: '聯邦銀行',
				SKBank: '新光銀行',
				Fubon: '富邦銀行',
				FirstBank: '第一銀行'
			}
		end
	end
end