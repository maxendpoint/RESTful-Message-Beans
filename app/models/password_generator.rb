require 'rubygems'
require 'ngrams'

class PasswordGenerator
  def initialize(file = Ngram::Dictionary::DEFAULT_STORE)
    @dictionary = Ngram::Dictionary.load(file)
  end
  
  def generate_password(length)
    @dictionary.word(length)
  end
end


