=begin

# Thoughts

Embeds can be categorized along three dimensions:

## Resource

The resource is the type of thing you are embedding. The contents of the embed
will depend on the resource. Each resource will include different code and
configuration options (the literal contents of the embed). 

* Documents
* Pages (currently uses Document as its model)
* Notes
* Search

## Request Strategy

* oEmbed
* Literal

## DOM Mechanism

The mechanism used for containing the contents of an embed. Effectively there
are two types of mechanisms: inserting a JS application directly into the
embedding DOM, or inserting an iFrame which contains the contents of the embed.

* in-DOM (direct)
* iFrame

## Embedding Context

Embedding context is the manner in which the embed code is introduced to the web
page it has been instructed to load on (either contained in the markup sent to
the browser, or inserted dynamically via javascript). The embedding context is
generally not known to the embed generator.

* Embedded in markup (server_side)
* Client-side injection (client_side)

=end

require_relative 'embed/base'
require_relative 'embed/document'
require_relative 'embed/page'
require_relative 'embed/note'
require_relative 'embed/search'

# DC::Embed is a collection of presenters which provide a 
# serializable representation of embeddable resources (for example, oEmbed).
module DC
  module Embed
    
    # List the resources which are supported for serialization
    EMBED_RESOURCE_MAP = {
      :document => self::Document,
      :page     => self::Page,
      :note     => self::Note,
      :search   => self::Search,
    }
    EMBEDDABLE_RESOURCES = EMBED_RESOURCE_MAP.keys
    
    # also list the mapping between model classes
    # and embeddable resources (where there is one).
    EMBEDDABLE_MODEL_MAP = {
      ::Document   => :document,
      ::Annotation => :note,
    }
    EMBEDDABLE_MODELS = EMBEDDABLE_MODEL_MAP.keys
    
    # Determine & return the appropriate presenter class for a resource
    def self.embed_type(resource)
      case
      when EMBEDDABLE_MODELS.any?{ |model_klass| resource.kind_of? model_klass }
        # by looking up whether the resource's model is embeddable
        EMBEDDABLE_MODEL_MAP[resource.class]
      when EMBEDDABLE_RESOURCES.include?(resource.type)
        # or if the resource specifies a type of embed explicitly.
        resource.type
      else
        # set up a system to actually register types of things as embeddable
        raise ArgumentError, "#{resource} is not registered as an embeddable resource"
      end
    end
    
    def self.embed_klass(type)
      raise ArgumentError, "#{type} is not a recognized resource type" unless EMBEDDABLE_RESOURCES.include? type
      EMBED_RESOURCE_MAP[type]
    end
    
    def self.embed_for(resource, config={}, options={})
      self.embed_klass(self.embed_type(resource)).new(resource, config, options)
    end
  end
end
