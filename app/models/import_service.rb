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
      when "E" then process_company(row, line_number)
      when "V" then process_job(row, line_number)
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
    name = row[1]&.strip
    website_url = row[2]&.strip
    email = row[3]&.strip
    user_id = row[4]&.strip
    logo = Rails.root.join("spec", "support", "files", "logo.png")

    user = User.find_by(id: user_id)
    company = CompanyProfile.build(name: name, website_url: website_url, contact_email: email, logo: logo, user: user)
    company.valid?

    if company.errors.empty?
      company.save
      @companies_created += 1
      company.update(user: user)
    else
      @number_of_errors += 1
      @errors << { line: line_number, data: row.to_s, errors: company.errors.full_messages }
    end
  end

  def process_job(row, line_number)
    title = row[1]&.strip
    salary = row[2]&.strip
    salary_currency = JobPosting.salary_currencies[row[3]&.downcase.strip]
    salary_period = JobPosting.salary_periods[I18n.t("salary_period").invert[row[4]&.downcase.strip]]
    work_arrangement = JobPosting.work_arrangements[I18n.t("work_arrangement").invert[row[5]&.downcase.strip]]
    job_type_id = row[6]&.strip
    job_location = row[7]&.strip
    experience_level_id = row[8]&.strip
    company_id = row[9]&.strip

    company = CompanyProfile.find_by(id: company_id)
    job_type = JobType.find_by(id: job_type_id)
    experience_level = ExperienceLevel.find_by(id: experience_level_id)
    job_post = JobPosting.build(title: title, salary: salary, salary_currency: salary_currency, salary_period: salary_period,
                                work_arrangement: work_arrangement, description: "Default", job_location: job_location,
                                company_profile: company, job_type: job_type, experience_level: experience_level)

    if job_post.valid?
      job_post.save
      @jobs_created += 1
    else
      @number_of_errors += 1
      @errors << { line: line_number, data: row.to_s, errors: job_post.errors.full_messages }
    end
  end
end
