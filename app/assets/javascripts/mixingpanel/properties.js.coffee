class @MixingpanelProperties
  constructor: (url) ->
    @referer = url || $("body").data('referer') || document.referrer
    @uri = @_getUri()
    @host = @uri.host.toLowerCase().replace(/^www\./, '')

    @engine = @_getEngine()
    @search_terms = @_getSearchTerms()
    @type = @_getType()
  
  _getUri: ->
    keys = [ 'protocol', 'hostname', 'host', 
             'pathname', 'port', 'search', 'hash', 'href']

    anchor = document.createElement('a')
    anchor.href = @referer

    uri = {}
    uri[key] = anchor[key] for key in keys
    uri

  _getEngine: ->
    if @google()
      "google"
    else if @yahoo()
      "yahoo"
    else if @bing()
      'bing'
    else
      null

  _getSearchTerms: ->
    return [] if not @engine? or not @uri.search? or @uri.search is ""

    key = if @engine is 'yahoo' then 'p' else 'q' # Yahoo are special with a 'p'
    query_string = @uri.search.split("#{key}=")[1].split('&')[0]
    if query_string.indexOf('%20', 0) > 0
      query_string.split('%20')
    else
      query_string.split('+')

  _getType: ->
    if @referer == ""
      "Direct"
    else if @engine?
      "SEO"
    else
      "Referral"

  google: ->
    !@host.match(/plus.google\.[a-z]{2,4}/) && @host.match(/google\.[a-z]{2,4}/)

  yahoo: ->
    @host.match(/yahoo\.com$/)

  bing: ->
    @host.match(/bing\.com$/)      

  isInternal: ->
    if @host.match(/kelisto\.es$/) then true else false

  isSocial: ->
    (@host.match(/busuu\.com$/) or
     @host.match(/delicious\.com$/) or
     @host.match(/facebook\.com$/) or
     @host.match(/flickr\.com$/) or
     @host.match(/foursquare\.com$/) or
     @host.match(/plus.google\.com$/) or
     @host.match(/hi5\.com$/) or
     @host.match(/linkedin\.com$/) or
     @host.match(/myspace\.com$/) or
     @host.match(/pinterest\.com$/) or
     @host.match(/sonico\.com$/) or
     @host.match(/tuenti\.com$/) or
     @host.match(/tumblr\.com$/) or
     @host.match(/twitter\.com$/) or
     @host.match(/t\.co$/) or
     @host.match(/xing\.com$/))?

  pageName: ->
    page_name = "unknown"
    if ($('body.landing-page').html()?)
      page_name = "Landing Page: " + window.location.href.split("?")[0]
    else if ($('article').attr('data-page-name')?)
      page_name = $('article').attr('data-page-name')
    else if (window.location.pathname == '/')
      page_name = "Home"
    else if ($('article h1').html()?)
      page_name = $('article h1').html()
    else if ($('h1').html()?)
      page_name = $('h1').html()
    else if ($('article h2').html()?)
      page_name = $('article h2').html()
    else if ($('h2').html()?)
      page_name = $('h2').html()
    else if ($('article h3').html()?)
      page_name = $('article h3').html()
    else if ($('h3').html()?)
      page_name = $('h3').html()
    page_name
