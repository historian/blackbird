module Blackbird::Helpers::TypedColumns

  def integer(name, options={})
    column(name, :integer, options)
  end

  def float(name, options={})
    column(name, :float, options)
  end

  def decimal(name, options={})
    column(name, :decimal, options)
  end

  def string(name, options={})
    column(name, :string, options)
  end

  def text(name, options={})
    column(name, :text, options)
  end

  def boolean(name, options={})
    column(name, :boolean, options)
  end

  def binary(name, options={})
    column(name, :binary, options)
  end

  def datetime(name, options={})
    column(name, :datetime, options)
  end

  def date(name, options={})
    column(name, :date, options)
  end

  def timestamp(name, options={})
    column(name, :timestamp, options)
  end

  def timestamps
    datetime :created_at
    datetime :updated_at
  end
  
  Blackbird::Table::Builder.send(:include, self)
  
end
