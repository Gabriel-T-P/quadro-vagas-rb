require 'rails_helper'

describe 'Testes do javascript', type: :system do
  it 'exibe mensagem Bem-vindo! no root path', js: true do
    visit root_path

    expect(page).to have_content 'Bem-vindo!'
  end
end
