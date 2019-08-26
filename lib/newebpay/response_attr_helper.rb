module Newebpay
	module ResponseAttrHepler
		def convert_to_attr_key(term)
			term.to_s.underscore
		end
	end
end