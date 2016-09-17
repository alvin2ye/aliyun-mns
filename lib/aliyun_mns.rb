require "time"
require "uri"
require "digest"
require "base64"
require "openssl"
require "net/http"
require "json"
require "crack"

module AliyunMns
  class Error < StandardError; end

  def self.setup
    yield self
  end

  class << self
    attr_accessor :access_key, :secret_key, :api_version, :endpoint, :protocol

    def base64_hmac(data)
      Base64.encode64("#{OpenSSL::HMAC.digest("sha1", secret_key, data)}").strip
    end

    def authorization(op = {})
      body = [op[:method], op[:content_md5], op[:content_type],
      op[:date], "x-mns-version:#{api_version}", op[:resource]].join("\n")

      "MNS #{access_key}:#{base64_hmac(body)}"
    end

    def content_xml(content)
      content = <<-XML
<?xml version="1.0"?>
<Message xmlns="http://mqs.aliyuncs.com/doc/v1/">
  <MessageBody>#{content}</MessageBody>
</Message>
      XML
    end

    def send_msg(queue, content) 
      httpdate = Time.now.httpdate
      uri = URI.parse("#{protocol}://#{endpoint}/queues/#{queue}/messages")
      content = content_xml(content)
      content_md5 = Base64::encode64(Digest::MD5.hexdigest(content)).chop
      authorization_code = authorization(method: "POST",
                                         content_md5: content_md5,
                                         content_type: "text/xml;charset=utf-8",
                                         date: httpdate,
                                         resource: uri.path)

      request = Net::HTTP::Post.new(uri.path, {
        "Authorization" => authorization_code, 
        "Date" => httpdate,
        "Host" => uri.host,
        "x-mns-version" => api_version,
        "Content-Length" => content.size.to_s,
        "Content-MD5" => content_md5,
        "Content-type" => "text/xml;charset=utf-8"
      })

      request.body = content
      Net::HTTP.new(uri.host, uri.port).request(request)
    end

    def receive(queue)
      httpdate = Time.now.httpdate
      uri = URI.parse("#{protocol}://#{endpoint}/queues/#{queue}/messages")
      authorization_code = authorization(method: "GET",
                                         date: httpdate,
                                         resource: uri.path)

      request = Net::HTTP::Get.new(uri.path, {
        "Authorization" => authorization_code, 
        "Date" => httpdate,
        "Host" => uri.host,
        "x-mns-version" => api_version
      })

      response = Net::HTTP.new(uri.host, uri.port).request(request)

      JSON.parse(Crack::XML.parse(response.body).to_json)
    end

    def delete(queue, receipt_handle)
      httpdate = Time.now.httpdate
      uri = URI.parse("#{protocol}://#{endpoint}/queues/#{queue}/messages?ReceiptHandle=#{receipt_handle}")

      authorization_code = authorization(method: "DELETE",
                                         date: httpdate,
                                         resource: "#{uri.path}?#{uri.query}")

      request = Net::HTTP::Delete.new("#{uri.path}?#{uri.query}", {
        "Authorization" => authorization_code, 
        "Date" => httpdate,
        "Host" => uri.host,
        "x-mns-version" => api_version
      })

      Net::HTTP.new(uri.host, uri.port).request(request)
    end
  end
end
