# frozen_string_literal: true

module Ares
  # An iteration contains many stories
  class Iteration
    include DataStores

    attr_accessor :report
    attr_accessor :accepted_points, :name
    attr_accessor :start_date, :end_date

    alias to_s inspect

    def initialize(name:, number:, started_at:, ended_at:)
      @number = number
      @started_at = started_at
      @ended_at = ended_at
      @name = name
      @accepted_points = 0
    end

    def inspect
      "<Iteration name='#{name}' accepted_points=#{accepted_points} " \
      "stories_count=#{stories.length}>"
    end
  end
end
