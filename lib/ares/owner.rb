# frozen_string_literal: true

module Ares
  # an owner is responsible for stories
  class Owner
    include DataStores

    attr_accessor :name, :accepted_points
    attr_reader :iteration

    alias to_s inspect

    def initialize(name, iteration: nil)
      @iteration = iteration
      @name = name
      @accepted_points = 0
    end

    def primary
      return unless iteration

      Ares.owners_store[name]
    end

    def accepted_points_by_iteration
      @accepted_points_by_iteration ||= Hash.new { 0 }
    end

    def inspect
      "<Owner name='#{name}' accepted_points=#{accepted_points} " \
      "total_stories=#{stories.length} " \
      "share_of_total_points='#{share_of_total}' " \
      "share_of_total_stories=#{share_of_total_stories}>"
    end

    def points_by_iteration
      return if iteration

      {}.tap do |results|
        Ares.iterations.each do |iteration|
          results[iteration.name] = accepted_points_by_iteration[iteration.name]
        end
      end
    end

    def first_iteration_index
      return @first_iteration_index unless @first_iteration_index.nil?

      target = iterations.first.name

      @first_iteration_index = Ares.iterations.find_index do |ares_iteration|
        ares_iteration.name == target
      end
    end

    def share_of_total_stories
      share_of_total_stories_num.to_s + '%'
    end

    def share_of_total_stories_num
      return calculate_share_of_stories(iteration) if iteration

      calculate_share_of_stories(Ares)
    end

    def calculate_share_of_stories(subject)
      ((stories.length.to_f / subject.stories.length) * 100).round(2)
    end

    def share_of_total
      share_of_total_num.to_s + '%'
    end

    def share_of_total_num
      return calculate_share_of_points(iteration) if iteration

      calculate_share_of_points(Ares)
    end

    def calculate_share_of_points(subject)
      ((accepted_points.to_f / subject.accepted_points) * 100).round(2)
    end

    def to_csv
      return if iteration

      CSV.open("./output/#{name}.csv", 'wb', csv_options) do |csv|
        Ares.iterations[first_iteration_index..-1].each do |iteration|
          csv << csv_single_iteration(iteration)
        end
      end
    end

    def csv_options
      {
        write_headers: true,
        headers: %w[iteration points average stories
                    iteration_total_points iteration_total_stories]
      }
    end

    def csv_single_iteration(iteration)
      name = iteration.name
      [
        name,                           # iteration
        points_by_iteration[name],      # points
        points_average,                 # average
        iteration_stories_count(name),  # stories
        iteration.accepted_points,      # iteration_total_points
        iteration.stories.size          # iteration_total_stories
      ]
    end

    def points_average
      @points_average ||= (accepted_points.to_f / iterations.size).round(2)
    end

    def iteration_stories_count(name)
      iterations_store[name]&.owners_store&.[](self.name)&.stories&.length
    end
  end
end
