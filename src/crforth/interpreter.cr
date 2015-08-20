require "./dictionary"

module CRForth
  alias Num = (Int32 | Float64)
  alias Anything = (Int32 | String | Float64 | Symbol | Nil)
  
  module PrimitiveWords
    def dup
      @stack << @stack.last
      nil
    end
  
    def q_dup
      @stack << @stack.last unless @stack.last == 0
      nil
    end
  
    def drop
      @stack.pop
      nil
    end
  
    def swap
      @stack += [@stack.pop, @stack.pop]
      nil
    end
  
    def over
      a = @stack.pop
      b = @stack.pop
      @stack << b << a << b
      nil
    end
  
    def rot
      a = @stack.pop
      b = @stack.pop
      c = @stack.pop
      @stack << b << a << c
      nil
    end
  
    def plus
      a = @stack.pop as Num
      b = @stack.pop as Num
      @stack << a + b
      nil
    end
  
    def mult
      a = @stack.pop as Num
      b = @stack.pop as Num
      @stack << a*b
      nil
    end
  
    def subtract
      a = @stack.pop as Num
      b = @stack.pop as Num
      @stack << b - a
      nil
    end
  
    def divide
      a = @stack.pop as Num
      b = @stack.pop as Num
      @stack << b / a
      nil
    end
  
    def dot
      @s_out.print( @stack.pop )
      nil
    end
  
    def cr
      @s_out.puts
      nil
    end
  
    def dot_s
      @s_out.print( "#{@stack}\n" )
      nil
    end
  
    def dot_d
      pp @dictionary
      nil
    end
  
    def hello
      puts "hello"
      nil
    end
  end
  
  class Interpreter
    include PrimitiveWords
  
    def initialize( s_in = STDIN, s_out = STDOUT )
      @s_in = s_in
      @s_out = s_out
      @dictionary = Dictionary.new
      @stack = [] of Anything
      initialize_dictionary
    end
  
    # Create all of the initial words.
    def initialize_dictionary
      word(":") do
        read_and_define_word
      end
  
      immediate_word( "\\" ) { @s_in.read_line; nil }
      word("bye"){ exit }
      word("+") {plus}
      word(".") {dot}
      word(".d") {dot_d}
      word(".s") {dot_s}
      word("*") {mult}
      word("-") {subtract}
      word("/") {divide}
      word("cr") {cr}
      word("hello") {hello}
    end
  
    # Convience method that takes a word and a closure
    # and defines the word in the dictionary
    def word( name, &block: -> Nil )
      @dictionary.word( name, &block )
    end
  
    # Convience method that takes a word and a closure
    # and defines an immediate word in the dictionary
    def immediate_word( name, &block: -> Nil )
      @dictionary.immediate_word( name, &block )
    end
  
    # Convience method that takes an existing dict.
    # word and a new word and aliases the new word to
    # the old.
    def alias_word( name: String, old_name: String )
      @dictionary.alias_word( name, old_name )
    end
  
    # Given the name of a new words and the words
    # that make up its definition, define the
    # new word.
    def define_word( name: String , words: Array(String) )
      @dictionary.word( name, &compile_words( words ) )
    end
  
    # Give an array of (string) words, return
    # A block which will run all of those words.
    # Executes all immedate words, well, immediately.
    def compile_words( words: Array(String) )
      blocks = [] of Proc(Nil)
      words.each do |word|
        entry = resolve_word( word )
        raise "no such word: #{word}" unless entry
        if entry.immediate
          entry.block.call
        else
          blocks << entry.block
        end
      end
      Proc(Nil).new{blocks.each {|b| b.call}; nil}
    end
  
    # Read a word definition from input and
    # define the word
    # Definition looks like:
    #  new-word w1 w2 w3 ;
    def read_and_define_word
      name = read_word
      words = [] of String
      while (word = read_word)
        break if word == ";"
        words << word
      end
      unless name.is_a?(Nil)
        @dictionary.word(name, &compile_words(words))
      end
    end
  
    # Given a (string) word, return the dictionary
    # entry for that word or nil.
    def resolve_word( word: String ): Entry | Nil
      return @dictionary.get(word) unless  @dictionary.get(word).is_a?(Nil)
      x = to_number(word)
      unless x.is_a?(Nil)
        block = ->{push_number(x)}
        return Entry.new(word, block, false)
      end
      nil
    end
  
    def push_number(x: Nil | Int32 | Float64)
      @stack << x
      nil
    end
  
    # Evaluate the given word.
    def forth_eval( word: String )
      entry = resolve_word(word)
      if entry.is_a?(Nil)
        @s_out.puts "#{word} ??"
      elsif entry.block.is_a?(Nil)
        @s_out.puts "#{word} ??"
      else
        entry.block.call
      end
    end
  
    def forth_eval(word: Nil)
      puts "Cant evaluate nil"
    end
  
    def to_float(word : String) : Float64?
      begin
       word.to_f
      rescue
       nil
      end
    end
  
    def to_int(word : String) : Int32?
      begin
       word.to_i
      rescue
       nil
      end
    end
  
    # Try to turn the word into a number, return nil if
    # conversion fails
    def to_number( word )
      if word.is_a?(Nil)
        return nil
      elsif (x = to_int(word))
        return x
      elsif (x = to_float(word))
        return x
      end
    end
  
    def read_word: String?
      result = nil
      ch = nil
      while true
        start_line = false

        ch = @s_in.read_char
        if ch.is_a?(Nil)
          break
        elsif result && ch.whitespace?
          break
        elsif result.is_a?(Nil)
          result = ch.to_s
        else
          result += ch
        end
      end
      return result if result
      nil
    end
  
    def read_string: String
    end
  
    def run
      while true
        word = read_word
        break unless word
        forth_eval( word )
        @s_out.flush
      end
    end
  end
end
