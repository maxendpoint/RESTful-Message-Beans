
require 'rubygems'
#require 'random/online'
require 'ngrams'

#class RandomBytesPool
  #def initialize(poolsize = 1024, source = Random::RandomOrg.new)
    #@poolsize = poolsize
    #@random_source = source
    #@position = @poolsize + 1
  #end
  
  #def next
    #if @position >= @poolsize
      #@pool = @random_source.randbyte(@poolsize)
      #@position = 0
    #end
    #@position += 1
    #@pool[@position - 1]
  #end
#end

#module Ngram
  #class Dictionary
    #@@random_bytes_pool = RandomBytesPool.new
    
    #def rand
      #@@random_bytes_pool.next / 255.0
    #end
  #end
#end

class PasswordGenerator
  def initialize(file = Ngram::Dictionary::DEFAULT_STORE)
    @dictionary = Ngram::Dictionary.load(file)
  end
  
  def generate_password(length)
    @dictionary.word(length)
  end
end



#generator = PasswordGenerator.new
#3.times { puts generator.generate_password(12) }

