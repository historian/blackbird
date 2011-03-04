# Blackbird::Transition is the coordinator of the transition process
class Blackbird::Transition

  def self.run!(*fragment_files)
    build(fragment_files).run!
  end

  def self.build(*fragment_files)
    new(fragment_files).build
  end

  attr_reader :fragment_files, :current, :future, :changes, :migration, :fragments

  def initialize(*fragment_files)
    @fragment_files = fragment_files.flatten.uniq.compact
  end

  def build
    load_fragments
    prepare_tmp_database
    load_current
    build_future
    analyze_changes
    build_migration

    self
  end

  def run!
    if @migration.instructions.empty?
      puts "Nothing changed, no migration was generated."
      return
    end
    
    migration = StringIO.new
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    
    last_table  = nil
    last_inst   = nil
    last_indent = 0

    migration.puts "class T#{timestamp} < ActiveRecord::Migration"
    migration.puts "  def self.up"
      @migration.instructions.each do |instruction|
        current_inst  = instruction[0]
        current_table = instruction[1]

        if [:create_table, :change_table, :drop_table].include? current_inst
          current_indent = 0
          current_args   = instruction[1..-1]
          args_string    = current_args.inspect[1..-2]
        else
          current_indent = 1
          current_args   = instruction[2..-1]
          args_string    = current_args.inspect[1..-2]
        end
        
        if (current_indent < last_indent or (current_table != last_table and last_table)) and last_inst != :drop_table
          migration.puts "    end"
          last_indent = 0
        end

        if current_indent > last_indent and current_table != last_table
          migration.puts ""
          migration.puts "    change_table(#{current_table.inspect}) do |t|"
        end

        if current_indent == 0
          migration.puts ""
          if [:create_table, :change_table].include? current_inst
            migration.puts "    #{current_inst}(#{args_string}) do |t|"
          else
            migration.puts "    #{current_inst}(#{args_string})"
          end
        else
          migration.puts "      t.#{current_inst}(#{args_string})"
        end

        last_inst   = current_inst
        last_table  = current_table
        last_indent = current_indent
      end

      if last_indent > 0
        migration.puts "    end"
      end
      migration.puts ""
    migration.puts "  end"
    migration.puts "end"
    
    File.open("db/migrate/#{timestamp}_t_#{timestamp}.rb", 'w+') do |f|
      f.write migration.string
    end

    self
  end

private

  def load_fragments
    @fragment_files.each do |path|
      require path
    end
  end

  def prepare_tmp_database
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3', :database => ':memory:')

    ActiveRecord::Migration.verbose = false

    # if File.file?("#{Rails.root}/db/schema.rb")
    #   load("#{Rails.root}/db/schema.rb")
    # end

    ActiveRecord::Migrator.migrate("db/migrate/", nil)
  end

  def load_current
    @current = Blackbird::Schema::Loader.load
  end

  def build_future
    @future = Blackbird::Schema.new
    @fragments = ActiveSupport::OrderedHash.new
    builder = Blackbird::Schema::Builder.new(@future)
    Blackbird::Fragment.subclasses.each do |fragment|
      fragment = fragment.new
      @fragments[fragment.class] = fragment
      fragment.apply(builder)
    end

    Blackbird.options[:processors].build.each do |processor|
      @future.process processor
    end
  end

  def analyze_changes
    @changes = Blackbird::Schema::Changes.analyze!(@current, @future)
  end

  def build_migration
    @migration = Blackbird::Migration.build(@current, @future, @changes)
  end

end
