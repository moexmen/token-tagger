# frozen_string_literal: true

# run rake data:load\[path_to_file\]
desc 'Load data from excel file'
namespace :data do
  desc 'Load data from excel file'
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
      puts "Unexpected number of sheets: #{sheets.length} in #{args[:file]}"
      return
    end

    sheet = sheets[0]
    school = nil
    students = []
    sheet.simple_rows.each_with_index do |row, idx|
      if idx == 0
        if !check_headers(HEADERS, row)
          puts "Something is wrong with the headers in #{args[:file]}"
          return
        end
        next
      end

      row.transform_keys! { |k| strip_spaces(k) }

      # hard validation checks
      # though don't even check or log if the row is completely empty, esp for files with 1 mil sparse rows
      if row.length == 0
        next
      end
      if !include_row?(row)
        puts "Skipped #{row.values}"
        next
      end
      
      if school.nil?
        school = School.new({ code: row[HEADERS[:school_code]], name: row[HEADERS[:school_name]], cluster: row[HEADERS[:school_cluster]] })
      end
      
      ### process contact numbers

      if row[HEADERS[:contact_number]].nil?
        # soft validation - blank contact should not happen, but is permitted
        # however, still substitute it with placeholder value (.dup to avoid frozen String)
        # the +65 will be added later
        puts "Blank contact for #{row.values}"
        row[HEADERS[:contact_number]] = "88888888".dup
      elsif row[HEADERS[:contact_number]].class == Integer
        # this happens if the cell is formatted as Number instead of General
        # coerce to string so that gsub doesn't break
        row[HEADERS[:contact_number]] = row[HEADERS[:contact_number]].to_s
      end

      orig_contact = row[HEADERS[:contact_number]].clone
      clean_contact!(row)
      if orig_contact.strip != row[HEADERS[:contact_number]]
        puts "Cleaned contact #{orig_contact} for #{row.values}"
      end

      # format local phone numbers
      # also do soft validation - highlight numbers or non-local numbers for human checks
      if row[HEADERS[:contact_number]].match(/^\d{8}$/)
        row[HEADERS[:contact_number]] = "+65#{row[HEADERS[:contact_number]]}"
      elsif row[HEADERS[:contact_number]].match(/^\+\d*$/)
        puts "Contact is international-looking and may require manual review #{row[HEADERS[:contact_number]]} for #{row.values}"
      else
        puts "Contact is not 8-digit yet also not international #{row[HEADERS[:contact_number]]} for #{row.values}"
      end

      ### process nric

      # some of entries have whitespace around it
      row[HEADERS[:nric]] = strip_spaces(row[HEADERS[:nric]])

      # semi-hard validation of NRIC -- while we still load the row, it has error status immediately set
      if valid_nric?(row)
        status = Student.statuses[:pending]
      else
        puts "Invalid NRIC #{row[HEADERS[:nric]]} #{row[HEADERS[:nric]].chars.map(&:ord)} for #{row.values}"
        status = Student.statuses[:error_nric]
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
      if !school.nil?
        school.save!
        Student.insert_all(students)
        puts "Inserted #{students.count} rows for #{school.name} from #{args[:file]}"
      else
        puts "No records in #{args[:file]}"
      end
    end
  rescue StandardError => e
    puts "Error inserting data for #{args[:file]}", e, e.backtrace
  end

  desc 'Load data from files'
  task :load_files, [:files] => :environment do |t, args|
    args[:files].split(',').each do |f|
      puts "Loading data from #{f}"
      Rake::Task["data:load"].invoke(f.strip)
    end
  end

  def strip_spaces(s)
    if !s.nil?
      # instead of \s which covers ASCII whitespace, use [[:space:]] to also cover
      # other Unicode whitespace characters (especially &nbsp;)
      s.gsub(/[[:space:]]+/, '')
    end
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
    return false if row[HEADERS[:serial_no]].nil?
    return false if row[HEADERS[:school_code]].nil?
    return false if row[HEADERS[:nric]].nil?
    return false if row[HEADERS[:token_requested]].nil?

    token_requested = strip_spaces(row[HEADERS[:token_requested]]).upcase
    return false if token_requested != 'Y' && token_requested != 'YES'
    
    # these columns reflect that they think token was collected before at various
    # points.
    # only reject Y, as it may be legitly blank in some cases
    return false if row[HEADERS[:govtech]] == 'Y'
    #return false if row[HEADERS[:token_taken]] == 'Y'

    true
  end

  def valid_nric?(row)
    IdentifierValidator.valid_format?(row[HEADERS[:nric]])
  end

  def clean_contact!(row)
    row[HEADERS[:contact_number]].gsub!(/[^\+0-9]/,'')
  end
end
