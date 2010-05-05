class Transitions::SchemaLoader

  def self.load
    new.load
  end

  def load
    schema = Transitions::SchemaDefinition.new
    builder = Transitions::SchemaBuilder.new(schema)

    connection.tables.each do |table|
      pk_name = connection.primary_key(table)
      has_pk  = !!pk_name

      builder.table(table, :id => has_pk, :primary_key => pk_name) do |t|

        connection.columns(table).each do |column|
          next if column.name == pk_name

          options = {}

          if !column.null.nil? and !column.null
            options[:null] = column.null
          end

          if column.limit and column.limit != 255
            options[:limit] = column.limit
          end

          if column.has_default?
            options[:default] = column.default
          end

          if column.type == :decimal
            options[:scale]     = column.scale
            options[:precision] = column.precision
          end

          t.column(column.name, column.type, options)

        end

        connection.indexes(table).each do |index|

          options = {
            :name => index.name
          }

          if index.unique
            options[:unique] = index.unique
          end

          t.index(index.columns, options)

        end

      end
    end

    schema
  end

private

  def connection
    ActiveRecord::Base.connection
  end

end