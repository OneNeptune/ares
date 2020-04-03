# frozen_string_literal: true

STORY_FIELDS = %i[
  id title labels iteration_num iteration_start_raw iteration_end_raw type
  estimate current_state created_at_raw accepted_at_raw requested_by
  owned_by
].freeze

module Ares
  # A story belongs to an iteration and an owner
  # it reflects estimated work to be done
  class Story
    attr_accessor(*STORY_FIELDS)

    def initialize(row:)
      STORY_FIELDS.each_with_index do |field, idx|
        instance_variable_set("@#{field}", row.fields[idx])
      end

      @iteration = iteration
    end

    def define_owner
      @ares_owner = ares_owner
      @iteration_owner = iteration_owner

      ares_owner.iterations_store[iteration.name] = iteration
      iteration_owner.iterations_store[iteration.name] = iteration
    end

    def process
      return if processed

      define_owner
      add_stories_to_stores
      process_points
    end

    def iteration
      Ares.iterations_store[iteration_num] ||= Iteration.new(iteration_details)
    end

    def iteration_name
      "#{date_time_from(iteration_start_raw).strftime('%y-%m-%d')}" \
      ' to ' \
      "#{date_time_from(iteration_end_raw).strftime('%y-%m-%d')}"
    end

    def iteration_details
      {
        name: iteration_name,
        number: iteration_num,
        started_at: date_time_from(iteration_start_raw),
        ended_at: date_time_from(iteration_end_raw)
      }
    end

    def ares_owner
      Ares.owners_store[@owned_by] ||= Owner.new(@owned_by)
    end

    def iteration_owner
      @iteration.owners_store[@owned_by] ||= Owner.new(@owned_by,
                                                       iteration: iteration)
    end

    def add_stories_to_stores
      [ares_owner, iteration_owner, iteration, Ares].each do |subject|
        subject.stories_store[id] = self
      end
    end

    def date_time_from(date_string)
      DateTime.strptime(date_string, '%d-%b-%y')
    end

    def accepted_at
      @accepted_at ||= date_time_from(@accepted_at_raw)
    end

    def created_at
      @created_at ||= date_time_from(@created_at_raw)
    end

    def owned_by
      @owned_by ||= Ares.owners[@owner] || Owner.new(@owner)
    end

    def estimate_int
      estimate.to_i
    end

    def processed
      Ares.processed_story_ids[@id]
    end

    def not_processed
      !processed
    end

    def process_points
      increment_accepted_points
      increment_accepted_points_by_iteration
      Ares.processed_story_ids[@id] = true
    end

    def increment_accepted_points
      [Ares, iteration, ares_owner, iteration_owner].each do |subject|
        subject.accepted_points += estimate_int
      end
    end

    def increment_accepted_points_by_iteration
      [ares_owner, iteration_owner].each do |subject|
        subject.accepted_points_by_iteration[iteration_name] += estimate_int
      end
    end
  end
end
