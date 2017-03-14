require "active_support"
require "http_fp/version"
require 'http_fp/utils'

module HttpFp
  include Utils
  mattr_accessor :verb, :with_host, :with_path, :with_query, :withUri, :with_json, :withHeaders, :add_headers,  :fetch, :to_curl, :out_curl, :resp_to_json, :to_uri

  @@empty_req = {host: nil, path: "/", query: {}, header: {}, method: "GET", body: ""}
  @@empty_resp = {status: nil, header: {}, body: {}}

  @@verb = -> verb { @@empty_req.merge({method: verb.upcase}) }
  @@with_host = -> host, req { req[:host] = host; req }.curry
  @@with_path = -> path, req { req[:path] = path; req }.curry
  @@with_query = -> params, req { req[:query] = params ; req }.curry
  @@with_json = -> hash, req { req[:body] = hash.to_json; req }.curry
  @@withHeaders = -> header, req { req[:header] = header ; req }.curry
  @@add_headers = -> header, req { req[:header].merge!(header); req }.curry

  @@resp_to_json = Utils.at.(:body) >>~ Utils.parse_json
  @@print = -> a { $stdout.puts a.pretty_inspect ; a }
  @@header_to_curl = -> a {
    "-H '#{a[0]}: #{a[1]}'"
  }
  @@to_uri = -> req {
    uri = URI(req[:host])
    req[:query] && uri.query = URI.encode_www_form(req[:query])
    uri.path = req[:path]
    uri}
  @@to_curl = -> req {
    %{curl -X '#{req[:method]}' '#{@@to_uri.(req).to_s}' #{req[:header].map(&@@header_to_curl).join(" ")}}
  }
  @@out_curl = -> req { @@print.(to_curl.(req)) ; req}
end
