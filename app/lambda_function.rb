require 'uri'
require 'net/http'

def get_color(status)
  colors = 
  {
    "SUCCEEDED" => "good",
    "FAILED" => "danger",
  }
  colors[status] || "warning"
end

def get_function_url(region, arn)
  "https://" + region + ".console.aws.amazon.com/states/home?region=" + region + "#/executions/details/" + arn
end

def get_function_name(arn)
  arn
end

def lambda_handler(event:, context:)
  region = event["region"] || ''
  detail = event["detail"]
  id = event["id"] || ''
  status = detail["status"] || ''
  arn = detail["executionArn"] || ''

  attachments = [
    {
      "color" => get_color(status),
      "title" => get_function_name(arn),
      "title_link" => get_function_url(region, arn),
      "text" => "*" + status + "*" + "\n",
      "footer" => id,
    }
  ]

  uri = URI.parse(ENV['SLACK_HOOK_URL'])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  req = Net::HTTP::Post.new(uri.path, initheader = { 'Content-Type' => 'application/json' })
  req.body = { "attachments" => attachments }.to_json
  res = http.request(req)
end
