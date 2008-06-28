module VersionSpecHelper

  # RandomHelper::Random.words defined in ../shared/random_words_helper.rb

  Version.fixture {{
    :content => RandomHelper::Random.words,
    :content_html => RedCloth.new(RandomHelper::Random.words).to_html,
    :created_at => Time::now,
    :signature => 'muchlovefromdefensio'
  }}
  
  Version.fixture(:spam) {{
    :content => RandomHelper::Random.words,
    :content_html => RedCloth.new(RandomHelper::Random.words).to_html,
    :created_at => Time::now,
    :number => 1,
    :spam => true,
    :spaminess => 0.99,
    :signature => 'nolovefromdefensio'
  }}
  
  def valid_version_attributes
    {
      :content => "I have content!"
    }
  end
end
