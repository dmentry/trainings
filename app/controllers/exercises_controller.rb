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
      award_every(current_user)
      @message = { notice: 'Упражнение добавлено успешно. Вы получаете новый уровень. Поздравляем!' } if achivs_add
      
      redirect_to @training, @message
    else
      # Если ошибки — рендерим здесь же шаблон тренировки (своих шаблонов у упражнения нет)
      render 'trainings/show', alert: "Упражнение добавить не удалось."
    end
  end

  def edit
    session[:ex_current_summ] = @exercise.summ

    # current_overall_exp = 0
    # current_user.exercise_name_vocs.each do |exercise_name_voc|
    #   current_overall_exp += exercise_name_voc.exp
    # end
    # session[:current_overall_exp] = current_overall_exp
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
    current_user.money += @exercise.summ / 3.0
    current_user.save!

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

        change_rank(current_user)

     next_level   
  end

  def achivs_edit
    current_user.money -= session[:ex_current_summ] / 3.0
    current_user.money += @exercise.summ / 3.0
    current_user.save!

    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)

    exercise_name_voc.exp = exercise_name_voc.exp - session[:ex_current_summ].to_i + @exercise.summ.round
    exercise_name_voc.save!

    next_level_exp = 0
    level = @exercise.level

    # next_level_exp_before = exercise_name_voc.exercises.order(id: :asc).last(2).first.next_level_exp
    next_level_exp_before = exercise_name_voc.exercises.order(id: :desc).find_by("id < ?", @exercise.id).next_level_exp
    
    # level_before = exercise_name_voc.exercises.order(id: :asc).last(2).first.level
    level_before = exercise_name_voc.exercises.order(id: :desc).find_by("id < ?", @exercise.id).level

    # Понизить или повысить ранг ####################################
    change_rank(current_user)
    # overall_exp = 0
    # current_user.exercise_name_vocs.each do |exercise_name_voc|
    #   overall_exp += exercise_name_voc.exp
    # end
    # current_rank_index = User.rank.index{ |x| x[0] == "#{current_user.rank}" }
    # previous_rank_index = current_rank_index - 1
    # next_rank_index = current_rank_index + 1

    # if overall_exp <= User.rank[current_rank_index][2]
    #   return if previous_rank_index < 0
    #   current_user.rank = User.rank[previous_rank_index][0]
    # end
    # if overall_exp > User.rank[current_rank_index][2]
    #   return if next_rank_index > 7
    #   current_user.rank = User.rank[next_rank_index][0]
    # end

    # current_user.save!
    #########################################################################

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

      @message = { notice: 'Упражнение изменено успешно. Ваш уровень понижен.' }
    else
     next_level_exp = next_level_exp_before
     @message = { notice: 'Упражнение изменено успешно.' }
    end

    @exercise.update_attributes!(next_level_exp: next_level_exp, level: level)
  end

  def achivs_delete
    current_user.money -= session[:ex_current_summ] / 3.0
    current_user.save!

    exercise_name_voc = ExerciseNameVoc.find(@exercise.exercise_name_voc_id)
    exercise_name_voc.exp = exercise_name_voc.exp - session[:ex_current_summ].to_i
    all_ex = exercise_name_voc.exercises.all.order(id: :desc)
    previous_exercise = all_ex.find_by("id < ?", @exercise.id)
    level_in_previous_exercise = previous_exercise.level
    exercise_name_voc.save!

    # Понизить ранг, если он был повышен ####################################
    change_rank(current_user)
    # overall_exp = 0
    # current_user.exercise_name_vocs.each do |exercise_name_voc|
    #   overall_exp += exercise_name_voc.exp
    # end
    # current_rank_index = User.rank.index{ |x| x[0] == "#{current_user.rank}" }
    # last_rank_index = current_rank_index - 1
    # if overall_exp <= User.rank[current_rank_index][2]
    #   current_user.rank = User.rank[last_rank_index][0]
    #   current_user.save!
    # end
    #########################################################################

    session[:ex_current_level] > level_in_previous_exercise
  end

  def change_rank(current_user)
    overall_exp = 0

    current_user.exercise_name_vocs.each do |exercise_name_voc|
      overall_exp += exercise_name_voc.exp
    end

    current_rank_index = User.rank.index{ |x| x[0] == "#{current_user.rank}" }
    next_rank_index = current_rank_index + 1
    previous_rank_index = current_rank_index - 1
    previous_rank_index = 0 if previous_rank_index < 0 
    last_rank_index = User.rank.index{ |x| x[0] == "#{User.rank.last[0]}" }
    first_rank_index = 0

    if overall_exp >= User.rank[next_rank_index][2] && current_rank_index != last_rank_index && current_user.rank != User.rank[next_rank_index][0]
      current_user.rank = User.rank[next_rank_index][0]
      current_user.money += 600
      current_user.save!
    end
    
    if overall_exp < User.rank[current_rank_index][2] && overall_exp >= User.rank[previous_rank_index][2] && current_rank_index != first_rank_index && current_user.rank != User.rank[previous_rank_index][0]
      current_user.rank = User.rank[previous_rank_index][0]
      current_user.money -= 600
      current_user.save!
    end

    current_user.save!
  end

  def award_every(current_user)
    if current_user.money * 3 % 200 == 0
      current_user.money += 300
      current_user.update(money: current_user.money += 300, awards: { label: "#{ current_user.money.round * 3 } повторов", date: "#{ Date.today }", pic: 'silver_bowl.png' })

      text = "Поздравляем! Вы  получаете достижение: #{current_user.money.round * 3} повторов. Награда: 300 пиастров."
    end
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
