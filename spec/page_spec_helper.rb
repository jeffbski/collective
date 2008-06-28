require File.join(File.dirname(__FILE__), 'version_spec_helper')

module PageSpecHelper

  include VersionSpecHelper

  # RandomHelper::Random.words defined in ../shared/random_words_helper.rb

  Page.fixture(:page) {{
    :name => 'good page',
    :id => 1,
    :slug => 'good page',
    :content => RandomHelper::Random.words
  }}
  
  Page.fixture(:page_with_several_versions) {{
    :name => 'good page',
    :id => 1,
    :slug => 'good page',
    :content => RandomHelper::Random.words
  }}
end
