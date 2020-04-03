# frozen_string_literal: true

module Ares
  # The processor takes a directory of files
  # and produces the necessary iterations
  class Processor
    attr_accessor :directory, :iterations

    def initialize(directory: nil, file: nil)
      @directory = directory
      @file = file
    end

    def go
      return process_directory if @directory
      return process_file if @file
    end

    def process_directory
      files.each do |file|
        @iterations = Iteration.new(file: file)
      end
    end

    def process_file
      content = File.read(@file)
      csv = CSV.new(content, headers: true)

      while (row = csv.shift)
        Ares.stories_store[row['Id']] = Story.new(row: row).process
      end
    end

    def rows(file = nil)
      @rows ||= CSV.read(file, headers: true)
    end

    def files
      Dir.glob(
        File.join(directory, '**', '*')
      ).select { |file| File.file?(file) }
    end
  end
end
