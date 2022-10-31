namespace :dev do

  DEFAULT_PASSWORD = 123456
  #  Rails.root indica o caminho até até a onde esta a aplicação, lib e tmp é a pasta a onde esta o arquivo
  # File.join ele é responsavel por colocar uma barra entre uma pasta e outra 

  DEFAULT_FILES_PATH = File.join(Rails.root, 'lib', 'tmp')

  desc "Configura o ambiente de desenvolvimento"
  task setup: :environment do
    if Rails.env.development?
      show_spinner("Apagando BD...") { %x(rails db:drop) }
      show_spinner("Criando BD...") { %x(rails db:create) }
      show_spinner("Migrando BD...") { %x(rails db:migrate) }
      show_spinner("Cadastrando administrador padrão...") { %x(rails dev:add_default_admin) }
      show_spinner("Cadastrando administradores extras...") { %x(rails dev:add_extra_admins) }
      show_spinner("Cadastrando usuário padrão...") { %x(rails dev:add_default_user) }
      show_spinner("Cadastrando assuntos padrões...") { %x(rails dev:add_subjects)}
      show_spinner("Cadastrando perguntas e respostas...") { %x(rails dev:add_answers_and_questions)}
    else
      puts "Você não está em ambiente de desenvolvimento"
    end
  end

  desc "Adiciona o administrador padrão"
  task add_default_admin: :environment do
    Admin.create!(
      email: 'admin@admin.com',
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc "Adiciona administrador extras"
  task add_extra_admins: :environment do
    10.times do |i|
    Admin.create!(
      email: Faker::Internet.email,
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
    end
  end

  desc "Adiciona o usuário padrão"
  task add_default_user: :environment do
    User.create!(
      email: 'user@user.com',
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  # Vou no arquivo subjects.txt pego uma linha e crio uma descrição na views
  desc "Adiciona assuntos padrões"
  task add_subjects: :environment do
    file_name = 'subjects.txt'
    file_path = File.join(DEFAULT_FILES_PATH, file_name)

    File.open(file_path, 'r').each do |line|
      Subject.create!(description: line.strip)
      / .strip - remove os spaços e barras  /
      puts "task rodou com sucesso!"
    end
  end

  desc "Adiciona perguntas e repostas"
  task add_answers_and_questions: :environment do
    Subject.all.each do |subject|
      rand(5..10).times do |i|
        params = { question: {
          description: "#{Faker::Lorem.paragraph} #{Faker::Lorem.question}",
          subject: subject,
          answers_attributes: []
        }}

        rand(2..5).times do |j|
          params[:question][:answers_attributes].push(
            { description: Faker::Lorem.sentence, correct: false } 
          )
        end

        index = rand(params[:question][:answers_attributes].size)
        params[:question][:answers_attributes][index] = {description: Faker::Lorem.sentence, correct: true }

        Question.create!( params[:question] )
      end
    end
  end

  private

  def show_spinner(msg_start, msg_end = "Concluído!")
    spinner = TTY::Spinner.new("[:spinner] #{msg_start}")
    spinner.auto_spin
    yield
    spinner.success("(#{msg_end})")
  end

end
