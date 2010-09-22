class Transitions::Processors::LocalizedColumns

  def visit_table(table)
    @current_table = table
  end

  def visit_column(column)
    options = column.options

    if options.delete(:localized)
      @current_table.remove_column(column.name)

      Transitions.options[:locales].each_key do |locale|
        name = "#{column.name}_t_#{locale.to_s.gsub('-', '_').downcase}"
        @current_table.add_column(name, column.type, options)
      end
    end

  end

end


=begin

post = Post.new
t = post.title_translations
t.class # => I18n::TranslationSet

t[:en] == t.en # => "Hello"
t[:fr] == t.fr # => "Bonjour"

# when I18N.locale # => :en
post.title # => "Hello"

# when I18N.fallback[:nl] # => :fr
t.nl # => "Bonjour"
t.nl(false) # => nil

# and when I18N.locale # => :nl
post.title # => "Bonjour"
post.title_t_nl # => nil

=end