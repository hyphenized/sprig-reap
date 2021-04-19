module Sprig::Reap
  class SeedFile
    include Logging

    DEFAULT_NAMESPACE = 'records'

    attr_reader :model

    def initialize(model)
      raise ArgumentError, 'Must initialize with a Sprig::Reap::Model' unless model.is_a? Model

      @model = model
    end

    def path
      Rails.root.join('db', 'seeds', Sprig::Reap.target_env, "#{model.to_s.tableize.gsub('/', '_')}.yml")
    end

    def exists?
      File.exists?(path)
    end

    def write
      initialize_file do |file, namespace|
        file.write model.to_yaml(:namespace => namespace)
        log_info "Successfully reaped records for #{model}...\r"
      end
    end

    private

    def initialize_file

      File.open(path, 'w') do |file|
        namespace = DEFAULT_NAMESPACE


        yield file, namespace
      end

    rescue => e
      log_error "There was an issue writing to the file for #{model}:\n#{e.message}"
      puts e.full_message
    end

    def existing_sprig_ids(yaml)
      return if yaml.empty?

      YAML.load(yaml).fetch(DEFAULT_NAMESPACE).to_a.map do |record|
        record.fetch('sprig_id')
      end
    end
  end
end
