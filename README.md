# Registry

Ruby class registry for registering, and looking up classes using a key, rather
than the class name. Decouples looking up classes from their name and namespace.

## Installation

```
gem install regstry
```

Note the missing `i` in the gem name. The name `registry` is taken by another gem.

## Usage

```ruby
class Obj
  include Registry
end

class One < Obj
  register :one
end

class Two < Obj
  register :two
end

one = Obj[:one].new
two = Obj[:two].new
```
