# frozen_string_literal: true

require 'csv'
require_relative 'ares/data_stores'
require_relative 'ares/iteration'
require_relative 'ares/owner'
require_relative 'ares/processor'
require_relative 'ares/story'

# Ares is the parent module/class for coordinating all the logic
# of processing each iteration's stories
module Ares
  class << self
    include DataStores
    attr_accessor :accepted_points, :processed_story_ids

    def process(directory: nil, file: nil)
      raise unless directory || file

      @processed_story_ids = Hash.new { false }
      @accepted_points = 0
      @processor = Processor.new(directory: directory, file: file)
      @processor.go
      self
    end

    def results
      @processor.results
    end

    def to_csv
      CSV.open('./output/ares.csv', 'wb', csv_options) do |csv|
        iterations.each do |iteration|
          @current_iteration = iteration
          csv << csv_single_iteration
        end
      end
    end

    def csv_options
      {
        write_headers: true,
        headers: %w[Iteration].push(*csv_owner_labels)
      }
    end

    def csv_owners
      @csv_owners ||= owners.reject { |owner| owner.accepted_points < 30 }
    end

    def csv_owner_labels
      csv_owners.map do |owner|
        [
          "#{owner.name} Points"
        ]
      end.flatten
    end

    def csv_single_iteration(iteration = @current_iteration)
      [iteration.name].push(*csv_owner_stats)
    end

    def csv_owner_stats
      csv_owners.map do |owner|
        [
          iteration_points_count(owner.name)
        ]
      end.flatten
    end

    def points_average
      @points_average ||= (accepted_points.to_f / iterations.size).round(2)
    end

    def iteration_points_count(owner_name)
      @current_iteration&.owners_store&.[](owner_name)&.accepted_points || 0
    end

    def iteration_stories_count(owner_name)
      @current_iteration&.owners_store&.[](owner_name)&.stories&.length || 0
    end
  end
end
