require 'rails/generators/rails/model/model_generator'

Rails::Generators::ModelGenerator.hook_for :transition,
  :in => :active_record,
  :default => true, :type => :boolean

module ActiveRecord
  module Generators
    class TransitionGenerator < Rails::Generators::NamedBase
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      def self.source_root
        @_tr_source_root ||= begin
          if base_name && generator_name
            File.expand_path('../templates', __FILE__)
          end
        end
      end

      def create_schema_file
        template 'fragment.rb', File.join('app/schema', class_path, "#{file_name.pluralize}_fragment.rb")
      end
    end
  end
end
