class ImportService
  require "csv"

  attr_reader :total_lines, :processed_lines, :number_of_errors, :users_created, :companies_created, :jobs_created, :errors

  def initialize(file)
    @file = file
    @total_lines = count_lines
    @processed_lines = 0
    @number_of_errors = 0
    @users_created = 0
    @companies_created = 0
    @jobs_created = 0
    @errors = []
  end

  def process
    CSV.foreach(@file, col_sep: ",").with_index(1) do |row, line_number|
      @processed_lines += 1

      case row[0]&.strip
      when "U" then process_user(row, line_number)
      when "E"
        # process_company(row, line_number)
      when "V"
        # process_job(row, line_number)
      else
        puts ("Linha ignorada: #{row}")
      end
    end
  end

  private

  def count_lines
    File.foreach(@file).count
  end

  def process_user(row, line_number)
    email = row[1]&.strip
    name = row[3]&.strip
    last_name = row[4]&.strip
    company_id = row[2]&.strip.presence

    user = User.build(email_address: email, name: name, last_name: last_name, password: "password123", password_confirmation: "password123")
    user.valid?
    if company_id
      company = CompanyProfile.find_by(id: company_id)
      user.errors.add(:company_profile, :company_not_found) unless company
    end

    if user.errors.empty?
      user.save
      @users_created += 1
      user.update(company_profile: company) if company_id
    else
      @number_of_errors += 1
      @errors << { line: line_number, data: row.to_s, errors: user.errors.full_messages }
    end
  end

  def process_company(row, line_number)
  end

  def process_job(row, line_number)
  end
end
