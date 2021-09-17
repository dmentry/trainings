module ExercisesHelper
  class Summ
    attr_accessor :label, :exercise

    def initialize(params)
      @label = params[:label] || ''

      @exercise = params[:exercise] || 0

      @exercise = @exercise.gsub(" ", "")
    end

    def overall
      if @exercise.split(',').size > 1 && !@label.match?(/лесен|Лесен|бег|лыжи|Бег|Лыжи|ОФП|Офп|офп/)
        overall_summ = 0

        @exercise.split(',') do |match|
          temp_summ = self.dash(@label, match)

          overall_summ += temp_summ if temp_summ

          temp_summ = self.multiply(@label, match)

          overall_summ += temp_summ if temp_summ

          temp_summ = self.one_rep(@label, match)

          overall_summ += temp_summ if temp_summ
        end

        return overall_summ
      elsif
        @label.match?(/ОФП|Офп|офп/)
          return self.ofp(@label, @exercise)
      else
        temp_summ_1 = self.dash(@label, @exercise) || 0

        temp_summ_2 = self.multiply(@label, @exercise) || 0

        temp_summ_3 = self.ladder(@label, @exercise) || 0

        temp_summ_4 = self.running(@label, @exercise) || 0

        temp_summ_5 = self.one_rep(@label, @exercise) || 0

        return temp_summ_1 + temp_summ_2 + temp_summ_3 + temp_summ_4 + temp_summ_5
      end
    end

  private
    # тире
    def dash(label, exercise)
      if !label.match?(/лесен|Лесен/) && exercise.match?(/-/)
        summ = 0

        exercise.split('-'){ |sub| summ += sub.to_i }

        summ
      end
    end

    # x
    def multiply(label, exercise)
      if exercise.match?(/[xXхХ]/)
        mult = 1

        exercise.split(/[xXхХ]/){ |sub| mult *= sub.to_i }

        mult = 0 if mult == 1

        mult
      end
    end

    # лесенка
    def ladder(label, exercise)
      if label.match?(/лесен|Лесен/)
        max = exercise.match(/(\A\d+\z)|(\d+\z)/).to_s.to_i

        result = 0

        max.times { |i| result += i }

        result = 2 * result + max

        result
      end
    end

    # бег\лыжи
    def running(label, exercise)
      exercise.match(/\d+[.,]\d+|\d+/).to_s.gsub(",", ".").to_f if label && label.match?(/бег|лыжи|Бег|Лыжи/)
    end

    # офп
    def ofp(label, exercise)
      if label && label.match?(/ОФП|Офп|офп/)
        temp_value = exercise.match(/(\d+(x|X|х|Х)\d+)/).to_s

        summ = self.multiply(label, temp_value)
      end
    end

    # один подход
    def one_rep(label, exercise)
      unless label.match?(/лесен|Лесен|бег|лыжи|Бег|Лыжи/)
        exercise.match(/\A\d+\z/).to_s.to_i if exercise.match?(/\A\d+\z/)
      end
    end
  end
end
