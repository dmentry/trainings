class ExercisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_training, only: [:create, :destroy, :update, :edit]
  before_action :set_exercise, only: [:destroy, :update, :edit, :achivs_add]

  # POST /exercises
  def create
    @exercise = @training.exercises.build(exercise_params)

    @message = { notice: 'Упражнение добавлено успешно.' }

    if @exercise.save
      count_summ
      is_new_level = achivs_add
      @message = { notice: 'Упражнение добавлено успешно. Вы получаете новый уровень. Поздравляем!' } if is_new_level
      
      redirect_to @training, @message
    else
      # Если ошибки — рендерим здесь же шаблон тренировки (своих шаблонов у упражнения нет)
      render 'trainings/show', alert: "Упражнение добавить не удалось."
    end
  end

  def edit
    session[:ex_current_summ] = @exercise.summ.to_i
  end

  def update
    # можно редактировать только последнее упражнение
    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)
    if @exercise == exercise_name_voc.exercises.order(id: :asc).last
     if @exercise.update(exercise_params)
        count_summ
        achivs_edit
      else
        @message = { alert: 'Упражнение не было изменено.' }
      end

      redirect_to @training, @message
      return
    else
      redirect_to @training, alert: 'Редактировать можно только последнее упражнение.'
    end
  end

  # DELETE /exercises/1
  def destroy
    # можно удалять только последнее упражнение и только если админ
    # if @exercise == Exercise.all.order(id: :asc).last && current_user.admin
    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)
    if @exercise == exercise_name_voc.exercises.order(id: :asc).last && current_user.admin
      session[:ex_current_summ] = @exercise.summ.to_i
      session[:ex_current_level] = @exercise.level

      if @exercise.destroy!
          @message = { notice: 'Упражнение удалено успешно.' }
          @message = { notice: 'Упражнение удалено успешно. Ваш уровень понижен.' } if achivs_delete
      else
        @message = { alert: 'Упражнение не было удалено.' }
      end

      redirect_to @training, @message

      return
    else
      redirect_to @training, alert: 'Удалить можно только последнее упражнение.'
    end
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

  def achivs_add
    ex_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)
    # exercise_name_voc.exp += @exercise.summ.round
    # next_level_exp = exercise_name_voc.exercises.order(id: :asc).last(2).first.next_level_exp
    # level = exercise_name_voc.exercises.order(id: :asc).last(2).first.level

    # if exercise_name_voc.exp >= exercise_name_voc.exercises.order(id: :asc).last(2).first.next_level_exp
    #   next_level_exp = next_level_exp(exercise_name_voc) + exercise_name_voc.exp
    #   level += 1
    #   @message = { notice: 'Упражнение добавлено успешно. Вы получаете новый уровень. Поздравляем!' }
    # end

    # exercise_name_voc.save!
    # @exercise.update_attributes!(next_level_exp: next_level_exp, level: level)

    next_level = AchievmentsHelper.exercise_exp_process(ex_name_voc, @exercise, current_user)
  end

  def achivs_edit
    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)

    exercise_name_voc.exp = exercise_name_voc.exp - session[:ex_current_summ].to_i + @exercise.summ.round

    next_level_exp = 0
    level = @exercise.level

    # next_level_exp_before = exercise_name_voc.exercises.order(id: :asc).last(2).first.next_level_exp
    next_level_exp_before = exercise_name_voc.exercises.order(id: :desc).find_by("id < ?", @exercise.id).next_level_exp
    
    # level_before = exercise_name_voc.exercises.order(id: :asc).last(2).first.level
    level_before = exercise_name_voc.exercises.order(id: :desc).find_by("id < ?", @exercise.id).level

    if (exercise_name_voc.exp >= next_level_exp_before) && (level == level_before)
      level += 1
      next_level_exp = AchievmentsHelper.c_next_level_exp(exercise_name_voc, @exercise, current_user) + exercise_name_voc.exp
      @message = { notice: 'Упражнение изменено успешно. Вы получаете новый уровень. Поздравляем!' }
    elsif (exercise_name_voc.exp >= next_level_exp_before) && (level > level_before)
      next_level_exp = AchievmentsHelper.c_next_level_exp(exercise_name_voc, @exercise, current_user) + exercise_name_voc.exp
      @message = { notice: 'Упражнение изменено успешно.' }
    elsif (exercise_name_voc.exp < next_level_exp_before) && (@exercise.level > level_before)
      level -= 1
      next_level_exp = next_level_exp_before
      # next_level_exp = next_level_exp(exercise_name_voc) + exercise_name_voc.exp
      @message = { notice: 'Упражнение изменено успешно. Ваш уровень понижен.' }
    else
     next_level_exp = next_level_exp_before
     @message = { notice: 'Упражнение изменено успешно.' }
    end

    exercise_name_voc.save!
    @exercise.update_attributes!(next_level_exp: next_level_exp, level: level)
  end

  def achivs_delete
    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)

    exercise_name_voc.exp = exercise_name_voc.exp - session[:ex_current_summ].to_i

    all_ex = exercise_name_voc.exercises.all.order(id: :desc)
    previous_exercise = all_ex.find_by("id < ?", @exercise.id)
    level_in_previous_exercise = previous_exercise.level

    # # next_level_exp = 0
    # # current_level = session[:ex_current_level].to_i
    # level = session[:ex_current_level].to_i

    # next_level_exp_before = exercise_name_voc.exercises.order(id: :asc).last.next_level_exp

    # level_before = exercise_name_voc.exercises.order(id: :asc).last.level

    # # if (exercise_name_voc.exp < next_level_exp_before) && (level > level_before)
    #   level -= 1
    #   @message = { notice: 'Упражнение удалено успешно. Ваш уровень понижен.' }
    # else
    #   @message = { notice: 'Упражнение удалено успешно.' }
    # end

    # next_level_exp = next_level_exp(exercise_name_voc) + exercise_name_voc.exp

    exercise_name_voc.save!
    # ex = exercise_name_voc.exercises.order(id: :asc).last(2).first
    # ex.update_attributes!(level: level, next_level_exp: next_level_exp)

    session[:ex_current_level] > level_in_previous_exercise
  end

  def next_level_exp(exercise_name_voc)
    next_level_exp = 0
    exercise_name_voc.exercises.order(id: :asc).last(3).each { |ex| next_level_exp += ex.summ }
    ((next_level_exp / 3)  * 3.15).round(1).round(half: :up)
  end

  def exercise_params
    params.require(:exercise).permit(:quantity, :note, :exercise_name_voc_id, :label, :summ)
  end
end
