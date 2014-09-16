require "schaldo/version"
require "active_support/configurable"
require "rest_client"
require "json"

module Schaldo
  include ActiveSupport::Configurable

  TOKEN_RENEWAL_EP = "/oauth/token"
  COMPANY_CLIENT_REGISTER_NEW = "/api/v1/company/client/register_new"
  BALANCE_CLIENT_INDEX_EP = "/api/v1/balance/client"
  BALANCE_CLIENT_EXPLAIN_EP = "/api/v1/balance/client/explain"
  BALANCE_CLIENT_TOPUP_EP = "/api/v1/balance/client/topup"
  BALANCE_CLIENT_WAITING_EP = "/api/v1/balance/client/topup/waiting_verification"
  BALANCE_CLIENT_TOPUP_DETAIL_EP = "/api/v1/balance/client/topup/detail"
  BALANCE_CLIENT_TOPUP_CHANGE_STATUS_EP = "/api/v1/balance/client/topup/change_status"

  module_function
  class << self
    def setup
      config.app_id = ""
      config.secret_id = ""
      config.server ||= "http://localhost:4002"
      yield config
    end
  end
  def token
    if @token == nil || (Time.now.to_i + 100) > @token_expired_time
      response = RestClient.post (Schaldo.config.server + Schaldo::TOKEN_RENEWAL_EP), {
          grant_type: "client_credentials",
          client_id: Schaldo.config.app_id,
          client_secret: Schaldo.config.secret_id
      }
      response = JSON.parse(response)

      @token = response["access_token"]
      @token_expired_time = Time.now.to_i + Integer(response["expires_in"])
    end
    @token
  end

end

require "schaldo/client"
require "schaldo/system"
require "schaldo/topup"