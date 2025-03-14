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

  describe '#process_user' do
    it 'success' do
      
    end
  end
end
