module DocumentConcerns
  module Canonical

    extend ActiveSupport::Concern

    DEFAULT_CANONICAL_OPTIONS = {
      :sections => true, :annotations => true, :contributor => true
    }

    DISPLAY_DATE_FORMAT     = "%b %d, %Y"


   # TODO: Make the to_json an extended form of the canonical.
    def as_json(opts={})
      json = {
        :id                  => id,
        :organization_id     => organization_id,
        :account_id          => account_id,
        :created_at          => created_at.to_date.strftime(DISPLAY_DATE_FORMAT),
        :access              => access,
        :page_count          => page_count,
        :annotation_count    => annotation_count || 0,
        :public_note_count   => public_note_count,
        :title               => title,
        :slug                => slug,
        :source              => source,
        :description         => description,
        :organization_name   => organization_name,
        :organization_slug   => organization_slug,
        :account_name        => account_name,
        :account_slug        => account_slug,
        :related_article     => related_article,
        :pdf_url             => pdf_url,
        :thumbnail_url       => thumbnail_url( { :cache_busting => opts[:cache_busting] } ),
        :full_text_url       => full_text_url,
        :page_image_url      => page_image_url_template( { :cache_busting => opts[:cache_busting] } ),
        :document_viewer_url => document_viewer_url,
        :document_viewer_js  => canonical_url(:js),
        :reviewer_count      => reviewer_count,
        :remote_url          => remote_url,
        :detected_remote_url => detected_remote_url,
        :publish_at          => publish_at.as_json,
        :hits                => hits,
        :mentions            => mentions,
        :total_mentions      => total_mentions,
        :project_ids         => project_ids,
        :char_count          => char_count,
        :data                => data,
        :language            => language
      }
      if opts[:annotations]
        json[:annotations_url] = annotations_url if commentable?(opts[:account])
        json[:annotations] = self.annotations_with_authors(opts[:account])
      end
      json
    end


    def canonical(options={})
      options = DEFAULT_CANONICAL_OPTIONS.merge(options)
      doc = ActiveSupport::OrderedHash.new
      doc['id']                 = canonical_id
      doc['title']              = title
      doc['access']             = ACCESS_NAMES[access] if options[:access]
      doc['pages']              = page_count
      doc['description']        = description
      doc['source']             = source
      doc['created_at']         = created_at.to_formatted_s(:rfc822)
      doc['updated_at']         = updated_at.to_formatted_s(:rfc822)
      doc['canonical_url']      = canonical_url(:html, options[:allow_ssl])
      doc['language']           = language
      if commentable?(options[:account])
        doc['annotations_url']  = annotations_url
      end
      if options[:contributor]
        doc['contributor']      = account_name
        doc['contributor_organization'] = organization_name
      end
      doc['display_language']   = display_language
      doc['resources']          = res = ActiveSupport::OrderedHash.new
      res['pdf']                = pdf_url
      res['text']               = full_text_url
      res['thumbnail']          = thumbnail_url
      res['search']             = search_url
      res['print_annotations']  = print_annotations_url
      res['translations_url']   = translations_url
      res['page']               = {}
      res['page']['image']      = page_image_url_template({ :local => options[:local], :cache_busting => options[:cache_busting] })
      res['page']['text']       = page_text_url_template(:local => options[:local])
      res['related_article']    = related_article if related_article
      res['annotations_url']    = annotations_url if commentable?(options[:account])
      if options[:allow_detected]
        res['published_url']    = published_url if published_url
      else
        res['published_url']    = remote_url if remote_url
      end
      doc['sections']           = ordered_sections.map {|s| s.canonical } if options[:sections]
      doc['data']               = data if options[:data]
      doc['language']           = language
      if options[:annotations] && (options[:allowed_to_edit] || options[:allowed_to_review])
        doc['annotations']      = self.annotations_with_authors(options[:account]).map {|a| a.canonical}
      elsif options[:annotations]
        doc['annotations']      = ordered_annotations(options[:account]).map {|a| a.canonical}
      end
      if self.mentions
        doc['mentions']         = self.mentions
      end
      doc
    end


    ############## path and url stuff


    def pathname
      Pathname.new File.join('documents', id.to_s)    
    end

    # Ex: docs/1011
    def path
      pathname.to_path
    end

    def slug_path(ext=".#{original_extension}")
      pathname.join(slug + ext).to_path
    end

    def original_file_path
      slug_path
    end

    # Ex: docs/1011/sec-madoff-investigation.txt
    def full_text_path
      slug_path('.txt')
    end

    # Ex: docs/1011/sec-madoff-investigation.pdf
    def pdf_path
      slug_path('.pdf')
    end

    # Ex: docs/1011/sec-madoff-investigation.rdf
    def rdf_path
      slug_path('.rdf')
    end

    # Ex: docs/1011/pages
    def pages_path
      pathname.join('pages').to_path
    end

    def annotations_path
      pathname.join('annotations').to_path
    end

    def canonical_id
      "#{id}-#{slug}"
    end

    def canonical_path(format = :json)
      "documents/#{canonical_id}.#{format}"
    end

    def canonical_cache_path
      "/#{canonical_path(:js)}"
    end

    def project_ids
      self.project_memberships.map {|m| m.project_id }
    end

    # Externally used image path, not to be confused with `page_image_path()`
    def page_image_template
      "#{slug}-p{page}-{size}.gif"
    end

    def page_text_template
      "#{slug}-p{page}.txt"
    end

    def public_pdf_url
      File.join(DC::Store::AssetStore.web_root, pdf_path)
    end

    def private_pdf_url
      File.join(DC.server_root, pdf_path)
    end

    def pdf_url(direct=false)
      return public_pdf_url  if public? || Rails.env.development?
      return private_pdf_url unless direct
      DC::Store::AssetStore.new.authorized_url(pdf_path)
    end

    def thumbnail_url( options={} )
      page_image_url( 1, 'thumbnail', options )
    end

    def page_image_url(page, size, options={} )
      path = page_image_path(page, size)
      if public?
        url = File.join( DC::Store::AssetStore.web_root, path )
        url << "?#{updated_at.to_i}" if options[:cache_busting]
        url
      else
        DC::Store::AssetStore.new.authorized_url path
      end
    end

    def public_full_text_url
      File.join(DC::Store::AssetStore.web_root, full_text_path)
    end

    def private_full_text_url
      File.join(DC.server_root, full_text_path)
    end

    def full_text_url(direct=false)
      return public_full_text_url if public? || Rails.env.development?
      return private_full_text_url unless direct
      DC::Store::AssetStore.new.authorized_url(full_text_path)
    end

    def document_viewer_url(opts={})
      suffix = ''
      suffix = "#document/p#{opts[:page]}" if opts[:page]
      if ent = opts[:entity]
        page  = self.pages.first(:conditions => {:page_number => opts[:page]})
        occur = ent.split_occurrences.detect {|o| o.offset == opts[:offset].to_i }
        suffix = "#entity/p#{page.page_number}/#{URI.escape(ent.value)}/#{occur.page_offset}:#{occur.length}"
      end
      if date = opts[:date]
        occur = date.split_occurrences.first
        suffix = "#entity/p#{occur.page.page_number}/#{URI.escape(date.date.to_s)}/#{occur.page_offset}:#{occur.length}" if occur.page
      end
      canonical_url(:html, opts[:allow_ssl]) + suffix
    end

    def canonical_url(format = :json, allow_ssl = false)
      File.join(DC.server_root(:ssl => allow_ssl, :agnostic => format == :js), canonical_path(format))
    end

    def search_url
      "#{DC.server_root}/documents/#{id}/search.json?q={query}"
    end

    def translations_url
      "#{DC.server_root}/translations/{realm}/{language}"
    end

    def annotations_url
      File.join(DC.server_root(:force_ssl => true, :agnostic => false ), annotations_path )
    end

    def print_annotations_url
      "#{DC.server_root}/notes/print?docs[]=#{id}"
    end

    # Internally used image path, not to be confused with page_image_template()
    def page_image_path(page_number, size)
      File.join(pages_path, "#{slug}-p#{page_number}-#{size}.gif")
    end

    def page_text_path(page_number)
      File.join(pages_path, "#{slug}-p#{page_number}.txt")
    end

    def public_page_image_template
      File.join(DC::Store::AssetStore.web_root, File.join(pages_path, page_image_template))
    end

    def private_page_image_template
      File.join(DC.server_root, File.join(pages_path, page_image_template))
    end

    def page_image_url_template(opts={})
      tmpl = if opts[:local]
               File.join(slug, page_image_template )
             elsif self.public? || Rails.env.development?
               public_page_image_template
             else
               private_page_image_template
             end
      tmpl << "?#{updated_at.to_i}" if opts[:cache_busting]
      tmpl
    end

    def page_text_url_template(opts={})
      return File.join(slug, page_text_template) if opts[:local]
      File.join(DC.server_root, File.join(pages_path, page_text_template))
    end





  end
end