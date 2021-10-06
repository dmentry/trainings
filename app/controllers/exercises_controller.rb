class ExercisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_training, only: [:create, :destroy, :update, :edit]
  before_action :set_exercise, only: [:destroy, :update, :edit, :achivs_add]

  def create
    @exercise = @training.exercises.build(exercise_params)

    @message = { notice: 'Упражнение добавлено успешно.' }

    if @exercise.save
      count_summ

      # award_every(current_user)

      @message = { notice: 'Упражнение добавлено успешно. Вы получаете новый уровень. Поздравляем!' } if ExercisesHelper.achivs_add(current_user, @exercise)
      
      redirect_to @training, @message
    else
      # Если ошибки — рендерим здесь же шаблон тренировки (своих шаблонов у упражнения нет)
      render 'trainings/show', alert: "Упражнение добавить не удалось."
    end
  end

  def edit
    session[:ex_current_summ] = @exercise.summ
  end

  def update
    # можно редактировать только последнее упражнение
    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)
    if @exercise == exercise_name_voc.exercises.order(id: :asc).last
     if @exercise.update(exercise_params)
        count_summ

        @message = ExercisesHelper.achivs_edit(current_user, @exercise, session[:ex_current_summ].to_i)
      else
        @message = { alert: 'Упражнение не было изменено.' }
      end

      redirect_to @training, @message

      return
    else
      redirect_to @training, alert: 'Редактировать можно только последнее упражнение.'
    end
  end

  def destroy
    # можно удалять только последнее упражнение и только если админ
    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)

    unless @exercise == exercise_name_voc.exercises.order(id: :asc).last && current_user.admin
      redirect_to @training, alert: 'Удалить можно только последнее упражнение.'
      return
    end
    ###############################################################

      session[:ex_current_summ] = @exercise.summ.to_i
      session[:ex_current_level] = @exercise.level.to_i

      if @exercise.destroy!
          @message = { notice: 'Упражнение удалено успешно.' }
          @message = { notice: 'Упражнение удалено успешно. Ваш уровень понижен.' } if ExercisesHelper.achivs_delete(
                                                                                         current_user, 
                                                                                         @exercise, 
                                                                                         session[:ex_current_summ], 
                                                                                         session[:ex_current_level]
                                                                                        )
      else
        @message = { alert: 'Упражнение не было удалено.' }
      end

      redirect_to @training, @message

      return

  end

  private

  def count_summ
    options = { exercise: @exercise.quantity, label: @exercise.exercise_name_voc.label }

    @exercise.summ = ExercisesHelper::Summ.new(options).overall

    @exercise.save!
  end
  
  def set_training
    @training = Training.find(params[:training_id])
  end

  def set_exercise
    @exercise = @training.exercises.find(params[:id])
  end

  def award_every(current_user)
    if current_user.money * 3 % 200 == 0
      current_user.money += 300
      current_user.update(money: current_user.money += 300, awards: { 
                                                                       label: "#{ current_user.money.round * 3 } повторов", date: "#{ Date.today }", 
                                                                       pic: 'silver_bowl.png' 
                                                                     })

      text = "Поздравляем! Вы  получаете достижение: #{current_user.money.round * 3} повторов. Награда: 300 пиастров."
    end
  end

  def achivs_add
    ExercisesHelper.achivs_add(current_user, @exercise)
  end

  def exercise_params
    params.require(:exercise).permit(:quantity, :note, :exercise_name_voc_id, :label, :summ)
  end
end
