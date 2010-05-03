class Transitions::SchemaLoader

  def self.load
    new.load
  end

  def load
    schema = Transitions::SchemaDefinition.new

    connection.tables.each do |table|
      pk_name = connection.primary_key(table)
      has_pk  = !!pk_name

      schema.create_table(table, :id => has_pk, :primary_key => pk_name) do |t|

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

          t.add_column(column.name, column.type, options)

        end

        connection.indexes(table).each do |index|

          t.add_index(index.columns,
            :name   => index.name,
            :unique => index.unique)

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