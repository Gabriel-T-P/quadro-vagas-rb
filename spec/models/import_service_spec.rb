require 'rails_helper'

RSpec.describe ImportService, type: :model do
  describe '#process_user' do
    it 'success' do
      user = create(:user, email_address: 'emailteste@teste.com')
      create(:company_profile, name: 'Company 1', contact_email: 'company1@email.com', id: 1)
      create(:company_profile, name: 'Company 2', contact_email: 'company2@email.com', id: 2, user: user)
      source = Rails.root.join('spec/support/files/import/user_text_test.txt')
      file = ImportService.new(source)

      file.process

      expect(file.total_lines).to eq 3
      expect(file.processed_lines).to eq 3
      expect(file.number_of_errors).to eq 0
      expect(file.users_created).to eq 3
      expect(file.companies_created).to eq 0
      expect(file.jobs_created).to eq 0
      expect(User.last.name).to eq 'Nome Teste 3'
      expect(User.last.last_name).to eq 'Sobrenome Teste 3'
      expect(User.last.email_address).to eq 'usuario3@example.com'
      expect(User.last.company_profile.id).to eq 2
      expect(User.first.company_profile).to eq nil
    end

    it 'with errors on creation' do
      create(:company_profile, name: 'Company 1', contact_email: 'company1@email.com', id: 1)
      source = Rails.root.join('spec/support/files/import/user_text_with_error_test.txt')
      file = ImportService.new(source)

      file.process

      expect(file.total_lines).to eq 3
      expect(file.processed_lines).to eq 3
      expect(file.number_of_errors).to eq 2
      expect(file.users_created).to eq 1
      expect(file.companies_created).to eq 0
      expect(file.jobs_created).to eq 0
      expect(User.last.name).to eq 'Nome Teste 1'
      expect(User.last.last_name).to eq 'Sobrenome Teste 1'
      expect(User.last.email_address).to eq 'usuario1@example.com'
      expect(User.last.company_profile).to eq nil
      expect(file.errors[0][:line]).to eq 2
      expect(file.errors[0][:errors]).to match_array [ 'Nome não pode ficar em branco', 'E-mail já está em uso' ]
      expect(file.errors[1][:line]).to eq 3
      expect(file.errors[1][:errors]).to match_array [ 'Sobrenome não pode ficar em branco', 'Perfil de Empresa não encontrada para o ID fornecido' ]
    end
  end

  describe '#process_company' do
    it 'success' do
      create(:user, email_address: 'emailteste@teste.com', id: 1)
      create(:user, email_address: 'emailteste2@teste2.com', id: 2)
      source = Rails.root.join('spec/support/files/import/company_text_test.txt')
      file = ImportService.new(source)

      file.process

      expect(file.total_lines).to eq 2
      expect(file.processed_lines).to eq 2
      expect(file.number_of_errors).to eq 0
      expect(file.users_created).to eq 0
      expect(file.companies_created).to eq 2
      expect(file.jobs_created).to eq 0
      expect(CompanyProfile.last.name).to eq 'Empresa B'
      expect(CompanyProfile.last.contact_email).to eq 'contato@empresa-b.com'
      expect(CompanyProfile.last.website_url).to eq 'https://www.empresa-b.com'
      expect(CompanyProfile.last.user.id).to eq 2
      expect(CompanyProfile.first.user.id).to eq 1
    end

    it 'with errors on creation' do
      create(:user, email_address: 'emailteste@teste.com', id: 1)
      create(:user, email_address: 'emailteste2@teste2.com', id: 2)
      source = Rails.root.join('spec/support/files/import/company_text_with_errors_test.txt')
      file = ImportService.new(source)

      file.process

      expect(file.total_lines).to eq 3
      expect(file.processed_lines).to eq 3
      expect(file.number_of_errors).to eq 1
      expect(file.users_created).to eq 0
      expect(file.companies_created).to eq 2
      expect(file.jobs_created).to eq 0
      expect(CompanyProfile.last.name).to eq 'Empresa B'
      expect(CompanyProfile.last.contact_email).to eq 'contato@empresa-b.com'
      expect(CompanyProfile.last.website_url).to eq 'https://www.empresa-b.com'
      expect(CompanyProfile.last.user.id).to eq 2
      expect(CompanyProfile.first.user.id).to eq 1
      expect(file.errors[0][:line]).to eq 3
      expect(file.errors[0][:errors]).to match_array [ 'User é obrigatório(a)', 'Nome não pode ficar em branco', 'URL do Site não pode ficar em branco', 'Email de Contato não pode ficar em branco', 'Email de Contato não é válido', 'URL do Site deve ser um URL válido (começar com http:// ou https://, ter ponto separando o domínio e terminar com uma extensão válida de 2 a 6 caracteres)' ]
    end
  end

  describe '#process_job' do
    it 'success' do
      user1 = create(:user, email_address: 'emailteste@teste.com', id: 1)
      user2 = create(:user, email_address: 'emailteste2@teste2.com', id: 2)
      user3 = create(:user, email_address: 'emailteste3@teste3.com', id: 3)
      create(:company_profile, name: 'Company 1', contact_email: 'company1@email.com', id: 1, user: user1)
      create(:company_profile, name: 'Company 2', contact_email: 'company2@email.com', id: 2, user: user2)
      create(:company_profile, name: 'Company 3', contact_email: 'company3@email.com', id: 3, user: user3)
      create(:job_type, id: 1, name: 'Teste 1')
      create(:job_type, id: 2, name: 'Teste 2')
      create(:job_type, id: 3, name: 'Teste 3')
      create(:experience_level, id: 1, name: 'Teste 1')
      create(:experience_level, id: 2, name: 'Teste 2')
      create(:experience_level, id: 3, name: 'Teste 3')
      source = Rails.root.join('spec/support/files/import/job_posting_text_test.txt')
      file = ImportService.new(source)

      file.process

      expect(file.total_lines).to eq 3
      expect(file.processed_lines).to eq 3
      expect(file.number_of_errors).to eq 0
      expect(file.users_created).to eq 0
      expect(file.companies_created).to eq 0
      expect(file.jobs_created).to eq 3
      expect(JobPosting.last.title).to eq 'Gerente de Projetos'
      expect(JobPosting.last.salary).to eq 8_000
      expect(JobPosting.last.salary_currency).to eq 'brl'
      expect(JobPosting.last.salary_period).to eq 'monthly'
      expect(JobPosting.last.work_arrangement).to eq 'hybrid'
      expect(JobPosting.last.job_location).to eq 'São Paulo'
      expect(JobPosting.last.company_profile.id).to eq 3
      expect(JobPosting.last.job_type.id).to eq 3
      expect(JobPosting.last.experience_level.id).to eq 3
      expect(JobPosting.first.company_profile.id).to eq 1
    end

    it 'with errors on creation' do
      user1 = create(:user, email_address: 'emailteste@teste.com', id: 1)
      user2 = create(:user, email_address: 'emailteste2@teste2.com', id: 2)
      user3 = create(:user, email_address: 'emailteste3@teste3.com', id: 3)
      create(:company_profile, name: 'Company 1', contact_email: 'company1@email.com', id: 1, user: user1)
      create(:company_profile, name: 'Company 2', contact_email: 'company2@email.com', id: 2, user: user2)
      create(:company_profile, name: 'Company 3', contact_email: 'company3@email.com', id: 3, user: user3)
      create(:job_type, id: 1, name: 'Teste 1')
      create(:job_type, id: 2, name: 'Teste 2')
      create(:job_type, id: 3, name: 'Teste 3')
      create(:experience_level, id: 1, name: 'Teste 1')
      create(:experience_level, id: 2, name: 'Teste 2')
      create(:experience_level, id: 3, name: 'Teste 3')
      source = Rails.root.join('spec/support/files/import/job_posting_text_with_error_test.txt')
      file = ImportService.new(source)

      file.process

      expect(file.total_lines).to eq 4
      expect(file.processed_lines).to eq 4
      expect(file.number_of_errors).to eq 1
      expect(file.users_created).to eq 0
      expect(file.companies_created).to eq 0
      expect(file.jobs_created).to eq 3
      expect(JobPosting.last.title).to eq 'Gerente de Projetos'
      expect(JobPosting.last.salary).to eq 8_000
      expect(JobPosting.last.salary_currency).to eq 'brl'
      expect(JobPosting.last.salary_period).to eq 'monthly'
      expect(JobPosting.last.work_arrangement).to eq 'hybrid'
      expect(JobPosting.last.job_location).to eq 'São Paulo'
      expect(JobPosting.last.company_profile.id).to eq 3
      expect(JobPosting.last.job_type.id).to eq 3
      expect(JobPosting.last.experience_level.id).to eq 3
      expect(JobPosting.first.company_profile.id).to eq 1
      expect(file.errors[0][:line]).to eq 4
      expect(file.errors[0][:errors]).to match_array [ 'Company profile é obrigatório(a)', 'Job type é obrigatório(a)', 'Experience level é obrigatório(a)', 'Título não pode ficar em branco', 'Salário não pode ficar em branco', 'Moeda não pode ficar em branco', 'Período do salário não pode ficar em branco', 'Company profile não pode ficar em branco', 'Arranjo de trabalho não pode ficar em branco' ]
    end
  end
end
