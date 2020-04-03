# frozen_string_literal: true

# Provides essential data stores
module DataStores
  def iterations_store
    @iterations_store ||= {}
  end

  def iterations
    iterations_store.values.sort_by { |it| -it.name }
  end

  def owners_store
    @owners_store ||= {}
  end

  def owners
    owners_store.values.sort_by { |it| -it.accepted_points }
  end

  def stories_store
    @stories_store ||= {}
  end

  def stories
    stories_store.values
  end
end
