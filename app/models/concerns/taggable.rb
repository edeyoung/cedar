module Taggable
  extend ActiveSupport::Concern

  def add_tag(tag)
    update(tags: (self['tags'] + [tag]).uniq)
  end

  def remove_tag(tag)
    update(tags: (self['tags'] - [tag]).uniq)
  end
end
