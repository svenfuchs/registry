require 'registry'

RSpec::Matchers.module_eval do
  define :have do |attrs|
    match { |obj| attrs.all? { |key, value| obj.send(key) == value } }
  end

  matcher :access do |key, const|
    match { |obj| obj[key] == const }
  end

  matcher :lookup do |key, const|
    match { |obj| obj.lookup(key) == const }
  end

  matcher :be_registered do |key|
    match { |obj| obj.registered?(key) }
  end
end
