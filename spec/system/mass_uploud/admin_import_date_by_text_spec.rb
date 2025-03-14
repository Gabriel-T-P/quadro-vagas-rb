require 'rails_helper'

describe 'Admin import data by text', type: :system do
  it 'by the navbar button' do
    admin = create(:user, role: :admin)

    login_as admin
    visit root_path

    expect(page).to have_link 'Importar Dados'
  end

  it 'non-admin user can not view button' do
    regular = create(:user, role: :regular)

    login_as regular
    visit root_path

    expect(page).not_to have_link 'Importar Dados'
  end

  it 'user must be admin' do
    regular = create(:user, role: :regular)

    login_as regular
    visit new_import_path

    expect(current_path).to eq root_path
    expect(page).to have_content 'Acesso não autorizado'
  end

  it 'user must be authenticated' do
    visit new_import_path

    expect(current_path).to eq new_session_path
  end

  it 'with success' do
    admin = create(:user, role: :admin)

    login_as admin
    visit new_import_path
    attach_file 'Selecione um arquivo CSV ou TXT', Rails.root.join('spec/support/files/import/import_text_test.txt')
    click_on 'Importar'

    expect(page).to have_content 'Importação iniciada com sucesso'
  end

  it 'and submit without selecting a file' do
    admin = create(:user, role: :admin)

    login_as admin
    visit new_import_path
    click_on 'Importar'

    expect(page).to have_content 'Por favor, selecione um arquivo para importar'
  end
end
