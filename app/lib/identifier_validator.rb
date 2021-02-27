# Taken from safe entry =P
class IdentifierValidator
  FIN_CHECK_DIGIT = {
    10 => 'K',
    9 => 'L',
    8 => 'M',
    7 => 'N',
    6 => 'P',
    5 => 'Q',
    4 => 'R',
    3 => 'T',
    2 => 'U',
    1 => 'W',
    0 => 'X'
  }.freeze

  FIN_INITIAL_DIGIT = {
    'F' => 0,
    'G' => 4
  }.freeze

  NRIC_CHECK_DIGIT = {
    10 => 'A',
    9 => 'B',
    8 => 'C',
    7 => 'D',
    6 => 'E',
    5 => 'F',
    4 => 'G',
    3 => 'H',
    2 => 'I',
    1 => 'Z',
    0 => 'J'
  }.freeze

  NRIC_INITIAL_DIGIT = {
    'S' => 0,
    'T' => 4
  }.freeze

  def self.valid_format?(identifier)
    return false if identifier.blank?

    identifier.upcase!
    valid_nric_format?(identifier) || valid_fin_format?(identifier)
  end

  def self.valid_fin_format?(identifier)
    valid?(identifier, FIN_INITIAL_DIGIT, FIN_CHECK_DIGIT)
  end

  def self.valid_nric_format?(identifier)
    valid?(identifier, NRIC_INITIAL_DIGIT, NRIC_CHECK_DIGIT)
  end

  def self.valid?(id_number, initial_digit, check_digit)
    return false unless id_number =~ /^[#{initial_digit.keys.join}]\d{7}[#{check_digit.values.join}]$/

    checksum(id_number, initial_digit, check_digit) == id_number[-1]
  end

  def self.checksum(id_number, initial_digit, check_digit)
    sum = 2 * id_number[1].to_i +
          7 * id_number[2].to_i +
          6 * id_number[3].to_i +
          5 * id_number[4].to_i +
          4 * id_number[5].to_i +
          3 * id_number[6].to_i +
          2 * id_number[7].to_i

    sum += initial_digit[id_number[0]]
    check_digit[sum % 11]
  end

  private_class_method :valid_fin_format?,
                       :valid_nric_format?,
                       :valid?,
                       :checksum
end
