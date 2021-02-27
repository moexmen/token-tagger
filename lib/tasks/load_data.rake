# frozen_string_literal: true

# run rake data:load\[path_to_file\]
desc 'Load data from excel file'
namespace :data do
  task :load, [:file] => :environment do |t, args|
    HEADERS = {
      serial_no: 'S/N',
      school_code: 'SchoolCode',
      school_cluster: 'SchoolCluster',
      school_name: 'SchoolName',
      level: 'StudentLevel',
      class: 'StudentClass',
      nric: 'StudentNRIC',
      name: 'StudentName',
      token_taken: 'TokenTaken(N)',
      contact_name: 'PrimaryPersonToContact(PPTC)Name',
      contact_number: 'PPTCContactNumber',
      govtech: 'GovTech',
      token_requested: 'TokenRequested(Y/N)'
      }.freeze

    xls = Creek::Book.new(args[:file], with_headers: true)
    sheets = xls.sheets

    if sheets.length != 1
      puts "Unexpected number of sheets: #{sheets.length}", args[:file]
      return
    end

    sheet = sheets[0]
    school = nil
    students = []
    sheet.simple_rows.each_with_index do |row, idx|
      break if idx == 0 && !check_headers(HEADERS, row)
      next if idx == 0

      row.transform_keys! { |k| strip_spaces(k) }

      if !include_row?(row)
        puts "Skipped #{row.values}"
        next
      end
      
      school = School.new({ code: row[HEADERS[:school_code]], name: row[HEADERS[:school_name]], cluster: row[HEADERS[:school_cluster]] }) if school.nil?
      
      contact = row[HEADERS[:contact_number]].clone
      clean_contact!(row)
      if contact.strip != row[HEADERS[:contact_number]]
        puts "Cleaned contact #{contact} for #{row.values}"
      end

      status = if valid_nric?(row)
                Student.statuses[:pending]
               else
                Student.statuses[:error_nric]
               end

      students.push({
        school_code: row[HEADERS[:school_code]],
        level: row[HEADERS[:level]],
        class_name: row[HEADERS[:class]],
        nric: row[HEADERS[:nric]],
        name: row[HEADERS[:name]],
        contact: row[HEADERS[:contact_number]],
        status: status,
        serial_no: row[HEADERS[:serial_no]],
        created_at: Time.now,
        updated_at: Time.now
      })
    end

    Student.transaction do
      school.save!
      Student.insert_all(students)
    end
  end

  def strip_spaces(s)
    s.gsub(/\s+/, '')
  end

  def check_headers(headers, header_row)
    sheet_headers = header_row.values.map { |h| strip_spaces(h) }
    missing_headers = []
    headers.values.each do |h|
      missing_headers << h unless sheet_headers.include?(h)
    end

    puts "Missing headers: #{missing_headers}" unless missing_headers.empty?
    missing_headers.empty?
  end

  def include_row?(row)
    return false if row[HEADERS[:token_requested]] != 'Y'
    return false if row[HEADERS[:govtech]] == 'Y'
    return false if row[HEADERS[:token_taken]] == 'Y'

    true
  end

  def valid_nric?(row)
    IdentifierValidator.valid_format?(row[HEADERS[:nric]])
  end

  def clean_contact!(row)
    row[HEADERS[:contact_number]].gsub!(/(-|\s+)/,'')
  end
end
