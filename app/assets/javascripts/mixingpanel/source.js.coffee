class @MixingpanelSource
  constructor: (@properties, options = {}) ->
    @cookies = new MixingpanelCookies()
    @expirationDays = options.firstTouchExpirationDays or 30
    @firstSourceProperty = "first_touch_source"
    @firstTimestampProperty = "first_touch_timestamp"
    @lastSourceProperty = "last_touch_source"
    @sourceProperty = "source"
    @sources =
      SEO: "SEO"
      SEM: "SEM"
      EMAIL: "Email"
      DIRECT: "Direct"
      SOCIAL: "Social"
      REFERRAL: "Referral"
    @_setUTM()
    @_setOptions(options)
    @append() unless options.append is false

  _setUTM: ->
    qsObj = @properties.location.query_string
    @utm =
      source: qsObj.utm_source
      medium: qsObj.utm_medium
      term: qsObj.utm_term
      content: qsObj.utm_content
      campaign: qsObj.utm_campaign

  _setOptions: (options) ->
    @appendSources(options.values) if options.values?
    @setValueCallback(options.callback) if options.callback?

  appendSources: (sources) ->
    $.extend(@sources, sources)

  setValueCallback: (callback) ->
    @getValue = callback if typeof callback is "function"

  getValue: () ->
    if @utm.medium?
      if @utm.medium is "email"
        @sources.EMAIL
      else if @utm.medium is "ppc" or @utm.medium is "banner"
        @sources.SEM
      else
        undefined

    else if @properties.engine?
      @sources.SEO

    else if @properties.referer isnt ""
      if @properties.isSocial()
        @sources.SOCIAL
      else
        @sources.REFERRAL

    else if @properties.referer is ""
      @sources.DIRECT
    else
      undefined

  append: ->
    value = @getValue()
    allSources = {}

    if @registerSource() and value?
      allSources = $.extend(allSources, @getFirstTouch(value)) if @firstTouchIsExpired()
      allSources = $.extend(allSources, @getLastTouch(value))
      mixpanel.register(allSources)

    allSources

  registerSource: ->
    @utm.medium? or !@properties.isInternal()

  firstTouchIsExpired: ()->
    if @cookies[@firstTimestampProperty]?
      false
    else
      @setFirstTouchExpirationCookie()
      true

  setFirstTouchExpirationCookie: ()->
    exp_days_ms = @expirationDays*24*60*60*1000
    current_time_ms = (new Date()).getTime()

    opts =
      domain: "." + @properties.internal_domain.match(/([^\.]+\.[^\.]+)$/)[1]
      expires_at: new Date(current_time_ms + exp_days_ms)

    @cookies.set(@firstTimestampProperty, @firstTimestampProperty, opts)

  getFirstTouch: (value)->
    @propertiesFor(value, "first_touch")

  getLastTouch: (value)->
    @propertiesFor(value, "last_touch")

  propertiesFor: (source, base_name = "last_touch")->
    props = {}
    props[base_name+"_source"]       = source
    props[base_name+"_timestamp"]    = new Date()
    props[base_name+"_referrer_url"] = @properties.uri.href if @properties.uri?
    props
