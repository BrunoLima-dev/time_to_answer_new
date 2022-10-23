class AdminsBackoffice::QuestionsController < AdminsBackofficeController
  before_action :set_question, only: [:edit, :update, :destroy] # Setar o questions antes de edit e update

  def index
    # Pego todos Questões pagino e ordeno por descrição
    @questions = Question.all.order(:id).page(params[:page]).per(10)  # Recebe todos as Questões com os seus valores
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(params_question)
    if @question.save
      redirect_to admins_backoffice_questions_path, notice: "Questões cadastrado com sucesso!"
    else
      render :new
    end
  end

  def edit; end

  def update
    if @question.update(params_question)
      redirect_to admins_backoffice_questions_path, notice: "Questões atualizado com sucesso!"
    else
      render :edit
    end
  end

  def destroy
    if @question.destroy
      redirect_to admins_backoffice_questions_path, notice: "Questões excluido com sucesso!"
    else
      render :index
    end
  end

  private

  def params_question
    params.require(:question).permit(:description)
  end

  def set_question
    @question = Question.find(params[:id])
  end
end

