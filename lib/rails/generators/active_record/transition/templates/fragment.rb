class <%= class_name.pluralize %>Fragment < Blackbird::Fragment

  table(:<%= class_name.gsub('::', '').underscore.pluralize %>) do |t|
<% for attribute in attributes -%>
    t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
<% if options[:timestamps] %>
    t.timestamps
<% end -%>
  end

end