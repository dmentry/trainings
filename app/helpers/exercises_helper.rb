module ExercisesHelper
  def self.summ(options={})
    name = options[:label] || ''

    exercise = options[:exercise]

    exercise = exercise.gsub(" ", "")

    # тире
    if !name.match?(/лесен/) && exercise.match?(/-/)
      summ = 0

      exercise.split('-'){ |sub| summ += sub.to_i }

      return summ
    end

    # x
    if exercise.match?(/[xXхХ]/)
      mult = 1

      exercise.split(/[xXхХ]/){ |sub| mult *= sub.to_i }

      return mult
    end

    # лесенка
    if name && name.match?(/лесен/)
      max = exercise.match(/(\A\d+\z)|(\d+\z)/).to_s.to_i

      result = 0

      (max).times { |i| result += i }

      result = 2 * result + max

      return result
    end

    # бег
    if name && name.match?(/бег|лыжи|Бег|Лыжи/)
      return exercise.match(/\d+[.,]\d+/).to_s.gsub(",", ".").to_f
    end

    # один подход
    if exercise.match?(/\A\d+\z/)
      return exercise.match(/\A\d+\z/).to_s.to_i
    end
  end
end
