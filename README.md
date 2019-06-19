# NewebpayRails
[藍新金流Newebpay](https://www.newebpay.com/)（前身為智付通spgateway）的Rails plugin

> - 參考[5xRuby](https://github.com/5xRuby)的[spgateway-rails](https://github.com/5xRuby/spgateway-rails)、[ZneuRay](https://github.com/ZneuRay)的[spgateway_rails](https://github.com/ZneuRay/spgateway_rails)與[CalvertYang](https://github.com/CalvertYang)的[spgateway](https://github.com/CalvertYang/spgateway)而成，特此感謝前人種樹，後人才有機會造林。
> - 請先註冊藍新會員（[正式環境](https://www.newebpay.com/website/Page/content/register)、[測試環境](https://cwww.newebpay.com/website/Page/content/register)），取得商店代號、hash_key、hash_iv，並啟用需要的付款方式。
> - 原始文件（[金流API](https://www.newebpay.com/website/Page/content/download_api)、[捐款API](https://donate.newebpay.com/download)）

## 安裝

Gemfile 加上:

```ruby
gem 'newebpay-rails', "~> 1.0"
```

執行:
```bash
$ bundle install
```

建立 `config/initializers/newebpay.rb`
```bash 
$ rails generate newebpay:install
```
輸入 `hash_key`, `hash_iv` 與 預設的商店代號 `merchant_id`

## 目錄

* [多功能收款 MPG](#多功能收款MPG)
* [信用卡定期定額](#信用卡定期定額)
* [交易查詢](#交易查詢)
* [信用卡取消授權](#信用卡取消授權)
* [信用卡請退款](#信用卡請退款)
* [捐款平台](#捐款平台)
* [其他](#其他)

## 多功能收款MPG

版本：1.5

完成 `config/initializers/newebpay.rb` 中的 `mpg_callback`, `notify_callback`, `payment_code_callback` 設定
- 若沒有設定 `notify_callback`，則只能使用即時交易支付方式（信用卡、WebATM、ezPay、Google Pay、Samsung Pay）
- 若沒有設定 `payment_code_callback`，則付款資訊直接顯示在藍新金流頁面上，且使用者不會被導回至網站。

```erb
# view
<%= newebpay_mpg_pay_button '顯示文字', payment_methods: [:credit_card, :vacc, :cvs, :barcode], 
order_number: "訂單編號", description: "商品資訊", price: "金額", email: "email", 
class: 'btn btn-success', id: 'payment' %>
```

參數 | 說明 | 必填 | 預設 
--- | --- | --- | ---
order_number | 商店訂單編號 <br><br>限英、數、`_`，上限30字。 <br> 同商店中不可重複。 | V |
description | 商品資訊 <br><br>上限50字。 | V |
price | 訂單金額 | V |
email | 付款人電子信箱 | V |
payment_methods | 付款方式，請使用[]，例如 `payment_methods: [:credit_card, :cvs]` <br><br> credit_card或credit：信用卡 <br> webatm：WEB ATM <br> vacc：ATM 轉帳 <br> cvs: 超商代碼 <br> barcode：超商條碼 <br> android_pay：Google Pay <br> samsung_pay：Samsung Pay <br> unionpay：銀聯卡 <br> p2g：ezPay <br> credit_red：信用卡紅利 <br><br> inst_flag：信用卡分期，請使用{}帶入值，如 `payment_methods: [:credit, :cvs, {inst_flag: "分期數"}]`。 <br> 1：開啟所有分期數。<br> 可分3,6,12,18,24,30期。 <br> 同時開啟多個期數時，使用`,`分隔，如：`{inst_flag: "3,6,12"}`。| V |
login_required | 藍新金流會員 <br><br>1：需要登入藍新會員 <br> 0：不需登入藍新金流會員 | V | 0 
merchant_id | 商店代號 | V | `config/initializers/newebpay.rb` 中的 `merchant_id` 
trade_limit | 交易限制秒數 <br><br> 數字限60 ~ 900。 | | 
expire_date | 繳費有效期限 <br><br> 日期Ymd，如 20150125。 <br> 上限180天。 | | 7天 
email_editable | 是否可修改Email <br><br> 1：可修改 <br> 0：不可修改 | | 0 
comment | 備註 <br><br> 上限300字 | | 
locale | 語系 <br><br> zh-tw或en | | zh-tw 
cancel_url | 取消支付返回網址 | | 
cvscom | 物流<br><br> 1：超商取貨不付款 <br> 2：超商取貨付款 <br> - 3：超商取貨不付款及超商取貨付款<br><br>金額限30元 ~ 20,000元。| | 

- 詳細說明參見[原文件](https://www.newebpay.com/website/Page/content/download_api)，部分參數名稱與預設值與原文件不同。
- 原文件其他的必填欄位會自動產生，不需處理。
- 原文件的ReturnURL、NotifyURL、CustomerURL已分別整合至`config/initializers/newebpay.rb`中的`mpg_callback`、`notify_callback`、`payment_code_callback`，不需再指定路徑。

在測試環境中
- 信用卡與分期付款，卡號請填4000-2211-1111-1111；紅利折抵請填4003-5511-1111-1111，到期日及背面三碼任意填寫。
- 銀聯卡不開放測試。
- WebATM將立刻完成交易並傳送交易完成資料。
- ATM轉帳、超商代碼、超商條碼可至測試後台點"模擬觸發"按鈕，會立刻傳送付款完成資料。
- Google Pay與Samsung Pay需使用綁定在裝置上的真實信用卡，但不會實際傳送資料至收單機構。
- 物流可測試物流訂單收單與透過寄件管理介面列印寄件代碼，列印寄件單與實際包裹貨態改變，需在正式環境並實際進行包裹交寄。
- ezPay可測試是否直接扣除帳戶金額。

**回傳參數**

- 參見原文件第六點
- 已解密TradeInfo，可直接使用
- 取得參數內容：call`underscore`後的原參數名稱
  - 例如：Result -> result，TradeNo -> trade_no

範例：
 ```ruby
config.notify_callback do |newebpay_response|
    if newebpay_response.success?
      Order.find_by(order_number: newebpay_response.result.merchant_order_no)
           .update_attributes!(paid: true)
    else
      Rails.logger.info "Newebpay Payment Not Succeed: #{newebpay_response.status}: #{newebpay_response.message} (#{newebpay_response.result.to_json})"
    end
  end
 ```

**取號完成回傳**

- 參見原文件第七點
- 說明同回傳參數

## 信用卡定期定額

版本：1.0

完成 `config/initializers/newebpay.rb` 中的 `periodical_callback`, `periodical_notify_callback` 設定
- 若沒有設定 `periodical_callback`，交易完成後，付款人將停留在藍新金流交易完成頁面。
- 若沒有設定 `periodical_notify_callback`，每期執行信用卡授權交易完成後，不會回傳資料。

```erb
# view
<%= newebpay_periodical_pay_button '顯示文字', order_number: "訂單編號", description: "產品名稱", 
price: "每期金額", email: "email", class: 'btn btn-success', id: 'periodical' %>
```

參數 | 說明 | 必填 | 預設 
--- | --- | --- | ---
order_number | 商店訂單編號 <br><br>限英、數、`_`，上限20字。 <br> 同商店中不可重複。 | V |
description | 產品名稱 <br><br>上限100字。 | V |
price | 委託金額 | V |
period_type | 授權週期 <br><br> daily：固定天數 <br> weekly：每週 <br> monthly：每月 <br> yearly：每年| V | monthly
period_point | 週期授權時間點 <br><br> 當`period_type`為`daily`時，限2 ~ 364，以授權日期隔日起算。<br> 當`period_type`為`weekly`時，限1 ~ 7，代表週一～週日 <br> 當`period_type`為`monthly`時，限01 ~ 31，代表1號~31號。若當月沒該日期，則自動調整為當月最後一天。 <br> 當`period_type`為`yearly`時，格式為日期 md ，如`0125`代表1月25日。 | V | 01 
period_times | 授權期數 （執行交易次數）<br><br>若期數大於信用卡到期日，則自動以信用卡到期日為最終期數。 | V | 99
check_type | 檢查模式 <br><br> 1：立刻執行10元授權。<br>若成功，將立即自動取消授權，付款人將不會被扣款。<br>若失敗，則該筆委託 單將自動取消。 <br><br> 2：立即執行委託金額授權<br><br> 3：不檢查 <br><br>詳細說明見原文件| V | 1 
email | 付款人電子信箱 | V |
merchant_id | 商店代號 | V | `config/initializers/newebpay.rb` 中的 `merchant_id`
email_editable | 是否可修改Email<br><br> 1：可修改<br> 0：不可修改 | | 0 
comment | 備註 <br> 上限300字 | |
payment_info | 是否開放填寫付款人資訊 <br><br> Y：是<br> N：否 | | N
order_info | 是否開放填寫收件人資訊 <br><br> Y：是<br> N：否 | | N
cancel_url | 取消支付返回網址 | | 

- 詳細說明參見[原文件](https://www.newebpay.com/website/Page/content/download_api)，部分參數名稱與預設值與原文件不同。
- 原文件其他的必填欄位會自動產生，不需處理。
- 原文件的ReturnURL、NotifyURL已分別整合至`config/initializers/newebpay.rb`中的`periodical_callback`、`periodical_notify_callback`，不需再指定路徑。

在測試環境中，卡號請填4000-2211-1111-1111，到期日及背面三碼任意填寫。

**回傳參數**

- 參見原文件第五、六點
- 已解密Period，可直接使用
- 取得參數內容：call`underscore`後的原參數名稱
  - 例如：Result -> result，TradeNo -> trade_no

範例：
 ```ruby
config.periodical_notify_callback do |newebpay_response|
    if newebpay_response.success? 
      PeriodicalTransaction.find_by(period_no: newebpay_response.result.period_no)
           .update_attributes!(paid: true)
    else
      Rails.logger.info "Newebpay Periodical Payment Not Succeed: #{newebpay_response.status}: #{newebpay_response.message} (#{newebpay_response.result.to_json})"
    end
  end
 ```

## 交易查詢

版本：1.1 

```ruby
# controller
query_trade_info(price: "訂單金額", order_number: "訂單編號").result
```

參數 | 說明 | 必填 | 預設 
--- | --- | --- | ---
order_number | 商店訂單編號 <br><br>限英、數、`_`，上限20字。 <br> 同商店中不可重複。 | V |
price | 訂單金額 | V |
merchant_id | 商店代號 | V | `config/initializers/newebpay.rb` 中的 `merchant_id`

- 詳細說明參見[原文件](https://www.newebpay.com/website/Page/content/download_api)，部分參數名稱與預設值與原文件不同。
- 原文件其他的必填欄位會自動產生，不需處理。

**回傳參數**

- 參見原文件第四點
- 取得參數內容：call`underscore`後的原參數名稱
```ruby 
	#controller
	#範例
	@response = query_trade_info(price: "訂單金額", order_number: "訂單編號")
	@response.success? #查詢是否成功
	@response.valid? #來源是否為藍新

	@response.result.merchant_order_no
	@response.result.payment_type
```

## 信用卡取消授權

版本：1.0 

執行條件
- 交易須為授權成功交易
- 必須在發動請款之前執行(預設自交易授權日起算 21 個日曆日晚上九點前)
- 完成取消授權的交易，將會於取消授權後，返還藍新金流商店及持卡人信用卡授權額度

```ruby 
# controller
cancel_auth(price: "取消授權金額", number_type: "1", order_number: "訂單編號/交易序號")
```
參數 | 說明 | 必填 | 預設 
--- | --- | --- | ---
number_type | 單號類別<br><br>1：使用訂單編號<br>2：金流交易序號 | V | 1 
order_number | 訂單編號/交易序號 <br><br>若`number_type`為`1`，請輸入商店訂單編號<br>若`number_type`為`2`，請輸入藍新金流交易序號。 | V | 
price | 取消授權金額 | V | 
merchant_id | 商店代號 | V | `config/initializers/newebpay.rb` 中的 `merchant_id`

- 詳細說明參見[原文件](https://www.newebpay.com/website/Page/content/download_api)，部分參數名稱與預設值與原文件不同。
- 原文件其他的必填欄位會自動產生，不需處理。

**回傳參數**

- 參見原文件第五、六點
- 取得參數內容：call`underscore`後的原參數名稱
- 依據信用卡收單金融機構規定不同，分為[即時處理]與[批次處理]兩種模式。
  - 批次處理資料會回傳至`config/initializers/newebpay.rb` 中的 `cancel_auth_notify_callback`

即時處理
```ruby 
	#controller
	#範例
	@response = cancel_auth(price: "取消授權金額", order_number: "訂單編號")
	@response.valid? #來源是否為藍新
	@response.success? #是否即時處理且是否成功
	@response.status == "TRA20001" #需由金融機構批次處理
	@response.message

	@response.result.trade_no
```

批次處理
```ruby
#範例
config.cancel_auth_notify_callback do |newebpay_response|
    if newebpay_response.success? && newebpay_response.valid?
      Order.find_by(order_number: newebpay_response.result.merchant_order_no)
    else
      Rails.logger.info "Newebpay Cancel Auth Not Succeed: #{newebpay_response.status}: #{newebpay_response.message} (#{newebpay_response.result.to_json})"
    end
  end
```

## 信用卡請退款

版本：1.1

請款執行條件
- 交易須為授權完成狀態
- 有效期限為授權成功日起算 21 個日曆日晚上九點前
- 一次付清交易的每筆請款金額必須小於或等於授權金額
- 分期付款交易、紅利折抵交易的每筆請款金額必須等於授權金額
- 取消請款需為發動請款當日的晚上九點前

退款執行條件
- 交易為已請款狀態
- 有效期限為請款日起算 90 個日曆日晚上九點前。(款項認列時間以收單機構為準。)
- 一次付清交易的每筆退款金額必須小於或等於請款金額。退款次數以每日一次為限
- 分期付款交易、紅利折抵交易的每筆退款金額必須等於請款金額，不可部份退款。
- 取消退款需為發動退款當日的晚上九點前

```ruby 
# controller
close_fund(price: "請退款金額", number_type: "1", order_number: "訂單編號/交易序號", close_type: :request)
```

參數 | 說明 | 必填 | 預設 
--- | --- | --- | ---
number_type | 單號類別<br><br>1：使用訂單編號<br>2：金流交易序號 | V | 1 
order_number | 訂單編號/交易序號 <br><br>若`number_type`為`1`，請輸入商店訂單編號<br>若`number_type`為`2`，請輸入藍新金流交易序號。 | V | 
price | 請退款金額 | V | 
close_type | 請款或退款<br><br>request：請款<br>refund：退款 | V | | 
abort | 取消請款或退款<br><br>true：取消請款或退款 | | |
merchant_id | 商店代號 | V | `config/initializers/newebpay.rb` 中的 `merchant_id`

- 詳細說明參見[原文件](https://www.newebpay.com/website/Page/content/download_api)，部分參數名稱與預設值與原文件不同。
- 原文件其他的必填欄位會自動產生，不需處理。

**回傳參數**

- 參見原文件第五點
- 取得參數內容：call`underscore`後的原參數名稱
```ruby 
	#controller
	#範例
	@response = close_fund(price: "請退款金額", number_type: "1", order_number: "訂單編號/交易序號", close_type: :request)
	@response.success? #請退款是否成功
	@response.message

	@response.result.merchant_order_no
```

## 捐款平台

> 請先申請[藍新金流捐款平台服務](https://donate.newebpay.com/apply)

版本：1.0

完成 `config/initializers/newebpay.rb` 中的 `periodical_callback`, `periodical_notify_callback` 設定
- 若沒有設定 `periodical_callback`，交易完成後，付款人將停留在藍新金流交易完成頁面。
- 若沒有設定 `periodical_notify_callback`，每期執行信用卡授權交易完成後，不會回傳資料。

```erb
# view
<%= newebpay_donation_pay_button "顯示文字", "捐款連結", order_number: "捐款單號", description: "捐款說明", price: "金額", 
class: 'btn btn-success', id: 'donation' %>
```

參數 | 說明 | 必填 | 預設 
--- | --- | --- | ---
order_number | 捐款單號 <br><br>限英、數、`_`，上限20字。 <br> 同商店中不可重複。 | V |
description | 捐款說明 <br><br>上限50字。 | V |
price | 金額 | V |
merchant_id | 商店代號 | V | `config/initializers/newebpay.rb` 中的 `merchant_id`
return_url | 完成捐款返回收款單位網址 <br><br>若不設定，則不顯示返回收款單位頁面按鈕，使用者將停留在藍新金流捐款完成頁面 | | 
payment_methods | 付款方式，請使用[]，例如 `payment_methods: [:credit_card, :cvs]` <br><br> credit_card或credit：信用卡 <br> webatm：WEB ATM <br> vacc：ATM 轉帳 <br> cvs: 超商代碼 <br> barcode：超商條碼 | | 全部啟用 
expire_date | 捐款有效期限，非即時交易的捐款有效天數 <br><br> 純數字，上限180。 | | 7 
template_type | 使用類型，將依此參數設定顯示捐款支付頁面項目之文字。<br><br> donate：捐款 <br> payment：繳款 | | donate 
anonymous | 匿名捐款 <br><br> on：匿名捐款<br>off：非匿名捐款<br> 若`template_type`為`payment`時，則固定為非匿名捐款，此參數無作用。 | | off 
name | 姓名/公司名稱 <br><br>上限30字 | | 
uni_no | 身份字號/統編 <br><br>上限10字 | | 
phone | 電話 <br><br>限數字、`-`，上限10字。 | | 
email | 電子信箱<br><br>上限50字| | 
id_address | 戶籍地址<br><br>上限100字| | 
address | 通訊地址<br><br>上限100字| | 
receipt_name | 收據抬頭 <br><br>上限30字 | | 
receipt_address | 收據地址 <br><br> 上限100字 | | 

- 詳細說明參見[原文件](https://donate.newebpay.com/download)，部分參數名稱與預設值與原文件不同。
- 原文件其他的必填欄位會自動產生，不需處理。
- 原文件的NotifyURL已整合至`config/initializers/newebpay.rb`中的`donation_notify_callback`，不需再指定路徑。

在測試環境中
- 信用卡卡號請填4000-2211-1111-1111，到期日及背面三碼任意填寫。
- WebATM將立刻完成交易並傳送交易完成資料。
- ATM轉帳、超商代碼、超商條碼可至測試後台點"模擬觸發"按鈕，會立刻傳送付款完成資料。

- 參見原文件第六點
- 取得參數內容：call`underscore`後的原參數名稱
  - 例如：Result -> result，TradeNo -> trade_no

範例：
 ```ruby
config.donation_notify_callback do |newebpay_response|
    if newebpay_response.success? && newebpay_response.valid?
      Donation.find_by(order_number: newebpay_response.result.merchant_order_no)
           .update_attributes!(paid: true)
    else
      Rails.logger.info "Newebpay Donation Payment Not Succeed: #{newebpay_response.status}: #{newebpay_response.message} (#{newebpay_response.result.to_json})"
    end
  end
 ```

## 其他

錯誤代碼解釋

錯誤代碼（回傳資料中的`status`）
```ruby 
Newebpay.get_error_message(error_code)
```

銀行英文代碼解釋

回傳資料中銀行英文代碼
```ruby 
Newebpay.bank(bank_code)
```

## License

[MIT](https://opensource.org/licenses/MIT).
