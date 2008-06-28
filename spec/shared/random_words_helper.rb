module RandomHelper
  #
  # RandomHelper::Random.words == "alias consequatur aut ..."
  #
  class Random
    # word list used for random generation
    WORDS = %w(alias consequatur aut perferendis sit voluptatem accusantium doloremque aperiam eaque ipsa quae ab illo inventore)

    # generate a list of words separated by spaces by randomly sorting WORDS
    def self.words # needs no external gems
      WORDS.sort_by { rand }.join(' ')
    end
  end
end