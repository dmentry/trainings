module ExercisesHelper
  class Summ
    attr_accessor :label, :exercise

    def initialize(params)
      @label = params[:label] || ''

      @exercise = params[:exercise] || 0

      @exercise = @exercise.gsub(" ", "")
    end

    def overall
      if @exercise.split(',').size > 1 && !@label.match?(/лесен|Лесен|бег|лыжи|ролики|Ролики|Бег|Лыжи|ОФП|Офп|офп/)
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
      else
        temp_summ_1 = self.dash(@label, @exercise) || 0

        temp_summ_2 = self.multiply(@label, @exercise) || 0

        temp_summ_3 = self.ladder(@label, @exercise) || 0

        temp_summ_4 = self.running(@label, @exercise) || 0

        temp_summ_5 = self.one_rep(@label, @exercise) || 0

        temp_summ_6 = self.rollerblade(@label, @exercise) || 0

        return temp_summ_1 + temp_summ_2 + temp_summ_3 + temp_summ_4 + temp_summ_5 + temp_summ_6
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

        max ** 2
      end
    end

    # бег\лыжи
    def running(label, exercise)
      exercise.match(/\d+[.,]\d+|\d+/).to_s.gsub(",", ".").to_f if label && label.match?(/бег|лыжи|Бег|Лыжи/)
    end

    # ролики
    def rollerblade(label, exercise)
      return if label && !label.match?(/ролики|Ролики/)

      result = exercise.scan(/(\d+[.,]?\d*)(\s?круг)?/).flatten

      kilo = result&.first&.gsub(",", ".").to_f if result&.size > 0
      krug = result&.last if !result.nil? && result&.size > 1

      kilo = kilo * 1.33 if krug

      kilo.round(1)
    end

    # один подход
    def one_rep(label, exercise)
      unless label.match?(/лесен|Лесен|бег|лыжи|Бег|Лыжи|ролики|Ролики/)
        exercise.match(/\A\d+\z/).to_s.to_i if exercise.match?(/\A\d+\z/)
      end
    end
  end
end
