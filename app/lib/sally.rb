module Sally
  API_ERROR = 'api_error'.freeze
  INVALID_NRIC = 'invalid_nric'.freeze
  INVALID_TOKEN = 'invalid_token'.freeze
  PERSON_HAS_TOKEN = 'person_has_token'.freeze
  TOKEN_ALREADY_ASSIGNED =  'token_already_assigned'.freeze
  
  class Client
    TOKEN_ALREADY_ASSIGNED_MESSAGE = 'Invalid Purchase Request: Duplicate identifier inputs'.freeze
    TOKEN_ALREADY_USED_MESSAGE = 'Invalid Purchase Request: Item already used'.freeze # Similiar to token already assigned, just that the SIOT API call failed. But it's the same to us.
    INVALID_TOKEN_MESSAGE = 'Invalid Purchase Request: Item not found'.freeze
    PERSON_QUOTA_REACHED = 'Exceeded limit. Please check the items before checking out.'.freeze
    INVALID_NRIC = 'Invalid Customer Id'.freeze
    INVALID_CONTACT = 'Invalid Purchase Request: Invalid identifier format'.freeze

    CONTACT_PLACEHOLDER = '+6588888888'

    def initialize(endpoint = '', client_secret = '')
      @endpoint = endpoint
      @client_secret = client_secret
    end

    def assign_token(token_id, student, tagger=nil)
      return { success: true } if student.assigned?

      contact = transform_contact(student.contact)
      contact_rejected = (contact == CONTACT_PLACEHOLDER)

      response = send_request(token_id, student.nric, contact)

      if ENV['RETRY_INVALID_CONTACT'].present?
        body = JSON.parse(response.body) unless response.body.blank?
        if body && body['message'] === INVALID_CONTACT
          contact_rejected = true
          Rails.logger.info { { student_id: student.id, student_name: student.name, message: 'Retrying due to invalid contact' } }
          response = send_request(token_id, student.nric, CONTACT_PLACEHOLDER)
        end
      end

      # Rails.logger.info { { student_id: student.id, student_name: student.name, response: response.body } }

      handle_response(student, token_id, contact_rejected, response, tagger)
    end

    private

    def transform_contact(contact)
      return CONTACT_PLACEHOLDER if contact.blank?
      return "+65#{contact}" if contact.match(/^\d{8}$/) #prepend +65 to 8 digit numbers
      return "+#{contact}" if contact.match(/^65\d{8}$/) #prepend +65 to 8 digit numbers

      contact
    end

    def handle_response(student, token_id, contact_rejected, response, tagger)
      body = JSON.parse(response.body) unless response.body.blank?
      message = body['message'] unless body.blank?

      if response.status == 200
        student.update({
          token_id: token_id,
          status: Student.statuses[:assigned],
          contact_rejected: contact_rejected,
          tagged_at: Time.now,
          batch: tagger
        })
        return { success: true }
      end

      if student.reload.assigned?
        return { success: true }
      end

      reason = message_to_reason(message)
      status = reason_to_status(reason)

      student.update({
        status: status,
        error_response: body,
        contact_rejected: contact_rejected,
        batch: tagger
      })

      return { success: false, reason: reason }
    end

    def reason_to_status(reason)
      case reason
      when Sally::PERSON_HAS_TOKEN
        Student.statuses[:error_quota]
      when Sally::INVALID_NRIC
        Student.statuses[:error_nric]
      else
        Student.statuses[:pending]
      end
    end

   def message_to_reason(message)
    case message
    when TOKEN_ALREADY_ASSIGNED_MESSAGE
      Sally::TOKEN_ALREADY_ASSIGNED
    when TOKEN_ALREADY_USED_MESSAGE
      Sally::TOKEN_ALREADY_ASSIGNED
    when INVALID_TOKEN_MESSAGE
      Sally::INVALID_TOKEN
    when INVALID_NRIC
      Sally::INVALID_NRIC
    when PERSON_QUOTA_REACHED
      Sally::PERSON_HAS_TOKEN
    else
      if message.blank?
        Sally::API_ERROR
      else
        message
      end
    end
   end

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
              value: token_id.upcase
            },
            {
              label: "Contact number",
              value: contact
            }
          ]
        }]
      }

      Faraday.new(url: @endpoint) { |f| f.response :logger, Rails.logger, :bodies => true, :headers => { :request => false, :response => true } }.post do |req|
        req.headers[ImmutableKey.new('x-api-key')] = @client_secret
        req.headers[ImmutableKey.new('content-type')] = 'application/json'

        req.body = body.to_json
      end
    end
  end

  class MockClient
    def initialize(endpoint = '', client_secret = '')
      @endpoint = endpoint
      @client_secret = client_secret
    end
    
    def assign_token(token_id, student, tagger=nil)
      student.update({ token_id: token_id, status: Student.statuses[:assigned], tagged_at: Time.now })
      { success: true }
    end
  end
end
