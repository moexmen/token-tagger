module Sally
  API_ERROR = 'api_error'.freeze
  INVALID_TOKEN = 'invalid_token'.freeze
  TOKEN_ALREADY_ASSIGNED =  'token_already_assigned'.freeze
  PERSON_HAS_TOKEN = 'person_has_token'.freeze
  
  class Client
    # ENDPOINT = ''.freeze
    TOKEN_ALREADY_ASSIGNED_MESSAGE = 'Invalid Purchase Request: Duplicate identifier inputs'
    INVALID_TOKEN_MESSAGE = 'Invalid Purchase Request: Item not found'
    # PERSON_QUOTA_REACHED = '' # TODO: check exact message returned by api

    def initialize(client_id = '', client_secret = '')
      @client_id = client_id
      @client_secret = client_secret
    end

    def assign_token(token_id, nric, contact)
      # TODO: make api call and return result
      # return { success: false, reason: API_ERROR | INVALID_TOKEN ...  } if api call fails
      { success: true }
    end
  end
end
