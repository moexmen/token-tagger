module Sally
  API_ERROR = 'api_error'.freeze
  INVALID_TOKEN = 'invalid_token'.freeze
  TOKEN_ALREADY_ASSIGNED =  'token_already_assigned'.freeze
  PERSON_HAS_TOKEN = 'person_has_token'.freeze
  
  class Client
    TOKEN_ALREADY_ASSIGNED_MESSAGE = 'Invalid Purchase Request: Duplicate identifier inputs'.freeze
    INVALID_TOKEN_MESSAGE = 'Invalid Purchase Request: Item not found'.freeze
    PERSON_QUOTA_REACHED = 'Exceeded limit. Please check the items before checking out.'.freeze
    INVALID_NRIC = 'Invalid Customer Id'.freeze
    INVALID_CONTACT = 'Invalid Purchase Request: Invalid identifier format'.freeze

    CONTACT_PLACEHOLDER = '88888888'

    def initialize(endpoint = '', client_secret = '')
      @endpoint = endpoint
      @client_secret = client_secret
    end

    def assign_token(token_id, nric, contact)
      if contact.blank?
        contact = CONTACT_PLACEHOLDER
        contact_rejected = true
      end

      response = send_request(token_id, nric, contact)

      contact_rejected = false
      body = JSON.parse(response.body) unless response.body.blank?
      if body && body['message'] === INVALID_CONTACT
        contact_rejected = true
        response = send_request(token_id, nric, CONTACT_PLACEHOLDER)
      end

      student = Student.where(nric: nric)
      if response.status == 200
        student.update({token_id: token_id, status: Student.statuses[:assigned], contact_rejected: contact_rejected})
        return { success: true }
      end
      
      if response.body.blank?
        student.update({contact_rejected: contact_rejected})
        return { success: false, reason: Sally::API_ERROR }
      end
      
      body = JSON.parse(response.body)
      reason = case body['message']
      when TOKEN_ALREADY_ASSIGNED_MESSAGE
        Sally::TOKEN_ALREADY_ASSIGNED
      when INVALID_TOKEN_MESSAGE
        Sally::INVALID_TOKEN
      when PERSON_QUOTA_REACHED
        Sally::PERSON_HAS_TOKEN
      else
        Sally::API_ERROR
      end

      status = if reason == Sally::PERSON_HAS_TOKEN
                 Student.statuses[:error]
               else
                Student.statuses[:pending]
               end

      student.update({ status: status, error_response: body, contact_rejected: contact_rejected })

      { success: false, reason: reason }
    end

    private

    def send_request(token_id, nric, contact)
      headers = {
        ImmutableKey.new('x-api-key') => @client_secret,
        ImmutableKey.new('content-type') => 'application/json'
      }

      body = {
        ids: [nric],
        transaction: [{
          category: "tt-token",
          quantity: 1,
          identifierInputs: [
            {
              label: "Device code",
              value: token_id
            },
            {
              label: "Contact number",
              value: contact
            }
          ]
        }]
      }

      Faraday.new(url: @endpoint).post do |req|
        req.headers[ImmutableKey.new('x-api-key')] = @client_secret
        req.headers[ImmutableKey.new('content-type')] = 'application/json'

        req.body = body.to_json
      end
    end
  end
end
