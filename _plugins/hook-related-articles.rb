Jekyll::Hooks.register :documents, :pre_render do |document, payload|

=begin
  Get related articles from each collection based on tag matches
  @todo : check that related articles are sort by date desc
=end

  isArticle = document.collection.metadata['isKB']

  if isArticle == true

    tags = document.data['tags']
    documentTagsNumber = tags.length
    related = []
    s = payload['site']
    maxRelated = s['maxRelated']
    minTagMatch = s['minTagMatch']
    relatedCount = 0
    matchedComplete = false

    if minTagMatch > documentTagsNumber
      minTagMatch = documentTagsNumber # lowering minTagMatch to pageTagsNumber - is it necessary ??
    end

    collections = s['collections'].reject { |c| !c['isKB'] }
    collections.each { |collection|
      collectionDocs  = collection['docs']

      (minTagMatch..documentTagsNumber).reverse_each { |numberOfTag|
        if matchedComplete == true
          break
        end

        collectionDocs.each { |article|
          if matchedComplete == true
            break
          end
          matchingTags = 0
          # Don't scan an article that is already in related or is current doc
          if related.include?(article) or article['title'] == document['title']
            next
          end
          articleTagsNumber = article['tags'].length
          # Not enough tags {{ articleTagsNumber }} need {{ numberOfTag }} to compete
          if articleTagsNumber < numberOfTag
            next
          end
          tags.each { |tag|
            if article['tags'].include?(tag)
              matchingTags += 1
              if matchingTags >= numberOfTag
                related.push article
                relatedCount += 1
                if relatedCount >= maxRelated
                  matchedComplete = true
                end
                break
              end
            end
          }
        }
      }
    }

    if related.length > 0
      document.data['related'] = related
    end

  end
end
