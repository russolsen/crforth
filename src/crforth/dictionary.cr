module CRForth
  class Entry
    property! name, block, immediate
  
    def initialize(name: String, block: Proc(Nil), immediate: Bool)
      @name = name
      @block = block
      @immediate = immediate
    end
  
    def dup
      Entry.new(@name, @block, @immediate)
    end
  end
  
  class Dictionary
    def initialize
      @entries = {} of String => Entry
    end
  
    def word( name: String , &block: -> Nil )
      @entries[name] = Entry.new(name, block, false)
      nil
    end
  
    def immediate_word( name: String , &block: -> Nil )
      @entries[name] = Entry.new(name, block, true)
    end
  
    def alias_word( name: String, old_name: String ): Bool
      entry = @entries[name]
      #raise "No such word #{old_name}" unless entry
      if ! entry.is_a?(Nil)
        new_entry = entry.dup
        new_entry.name = name
        @entries[name] = entry
        true
      else
        false
      end
    end
  
    def get( name ): Entry?
      # puts "Looking up #{name} in entries"
      # puts @entries.keys
      result = @entries[name]?
      # puts "result: #{result.class}"
      result
    end
  end
end
