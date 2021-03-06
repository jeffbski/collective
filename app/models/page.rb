require 'diff/lcs'

class Page 
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :name, String, :nullable => false
  attr_accessor :spam
  attr_accessor :spaminess
  attr_accessor :remote_ip
  attr_accessor :signature
  property :slug, String, :nullable => false
  property :versions_count, Integer, :default => 0
  has n, :versions, :spam => false 
  
  before :save, :build_new_version

  before :destroy do
    self.versions.each { |v| v.destroy }
  end

  validates_is_unique :slug
  validates_is_unique :name

  def self.by_slug(slug)
    first(:slug => slug)
  end
  
  def self.by_slug_and_select_version!(slug, version)
    page = by_slug(slug)
    page.select_version!(version) if page
    
    # Order matters! This is a little clever. If +try+ fails, +nil+ is 
    # returned, and therefore the search was invalid. If +try+ doesn't fail, 
    # +page+ must have been found and will be returned.
    return page.try(:selected_version) && page
  end
  
  attr_accessor :content_diff
  def content=(new_content)
    self.content_diff = diff(new_content)
    @content = new_content
  end
  
  def content
    @content ||= selected_version.try(:content) || ''
  end

  def content_html
    selected_version.try(:content_html) || ''
  end

  def latest_version
    Version.latest_version_for_page(self)
  end

  def name=(new_name)
    attribute_set(:name, new_name) if new_record?
    set_slug if new_record?
  end

  def select_version!(version_number=:latest)
    @selected_version = find_selected_version(version_number)
    self.content      = selected_version.try(:content)
    @selected_version
  end

  def selected_version
    @selected_version || latest_version
  end

  def self.slug_for(name)
    name = Iconv.iconv('ascii//translit//IGNORE', 'utf-8', name).to_s
    name.gsub!(/\W+/, ' ') # non-words to space
    name.strip!
    name.downcase!
    name.gsub!(/\s+/, '-') # all spaces to dashes
    name
  end

  def to_param
    slug
  end

private
  def diff(new_content)
    diff        = Diff::LCS.sdiff(content, new_content)
    all_changes = diff.reject { |diff| diff.unchanged? }
    additions   = all_changes.reject { |diff| diff.deleting? }
    additions.map { |diff| diff.to_a.last.last }.join
  end

  def build_new_version
    # DataMapper not initializing versions_count with default value of zero. Bug?
    self.versions_count ||= 0
    self.versions_count  += 1 unless spam
    
    # Don't use #build as it is NULLifying the page_id field of this page's other versions
    versions << Version.new(version_attributes)
  end
  
  def find_selected_version(version_number)
    if version_number.nil? || version_number == :latest
      latest_version
    else
      version_number = version_number.to_i
      versions.detect { |version| version.number == version_number }
    end
  end
  
  def version_attributes
    defaults = { 
      :content   => content, 
      :signature => signature
    }
    if spam
      defaults.update(
        :number    => versions_count.succ, 
        :spam      => true, 
        :spaminess => spaminess
      )
    else
      defaults.update(:number => versions_count)
    end
  end

  def set_slug
    self.slug = Page.slug_for(name) if new_record?
  end

end
