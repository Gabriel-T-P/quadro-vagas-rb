require 'rails_helper'

describe 'Admin uploud mass data by text', type: :system do
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

  it 'with success' do
    admin = create(:user, role: :admin)

    login_as admin
    visit new_import_path
    
  end
end
