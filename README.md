## Intro

aliyun-mns

阿里云消息队列

#### Usage

```

gem "aliyun-mns"

AliyunMns.setup do |config|
  config.access_key = 'abc...'
  config.secret_key = 'w5....'
  config.api_version = "2015-06-06"
  config.endpoint = "14589xxxxx.mns.cn-shanghai.aliyuncs.com"
  config.protocol = "http"
end

msg = '{"id": 123, "text": "eee"}'
p ["Send", AliyunMns.send_msg("item-dwg-upgrade", Base64.encode64(msg))]

msg = AliyunMns.receive("item-dwg-upgrade")
receipt_handle = msg["Message"]["ReceiptHandle"]
body = Base64.decode64(msg["Message"]["MessageBody"]) rescue nil

p ["receive", "body", body, "receipt_handle", receipt_handle ]

p ["delete", AliyunMns.delete("item-dwg-upgrade", receipt_handle)]

```
