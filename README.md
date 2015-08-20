# crforth

A simple FORTH interpreter (http://github.com/russolsen/rforth) ported
to the Crystal programming language.

Note that CRForth is an experiment in porting a non-trivial application
from Ruby to Crystal. The code is, as I write this, just barely working.
This is probably not idiomatic Crystal -- I'm still figuring out what that
means.

Some lessons so far:

* Most of the effort of the port involved minor changes to make the static typing
happy. For example, FORTH interpreter uses a lot of procs whose return values are ignored.
Eventually I had all of them return nil to make the static typing happy. I'm not sure
if this is really the correct thing, but it was expediant.

* The original Ruby version used metaprogramming to look at the methods available
in a module. I've done that by hand in CRForth because I don't see the equivalent
in Crystal.

* It is really cool to get a stand alone, binary executable from Rubyish code.

## Installation

Add it to `Projectfile`

```crystal
deps do
  github "[your-github-name]/crforth"
end
```

## Usage

```crystal
require "crforth"

i = CRForth::Interpreter.new
i.run
```

Or just run the interpreter from source:

```crystal
crystal src/main.cr
```

Right now CRForth doesn't have a great interface: It just silently prompts for
some FORTH code and executes it. To add 2 + 2 you would do the following:

```
~/projects/crystal/crforth: make run
crystal src/main.cr
2 2 + . cr
4
bye
````

## Development

There is a Makefile for convience. The targets are:

* crforth: Build the executable. This is the default.

* clean: Clean up any generated files.

* run: Runs the interpeter from source.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/crforth/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [russolsen](https://github.com/[russolsen]) Russ Olsen - creator, maintainer
