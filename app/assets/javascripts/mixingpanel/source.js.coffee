class @MixingpanelSource
  constructor: (@properties) ->
    @expirationDays = 30
    @firstSourceProperty = "first_touch_source"
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
    true

  _setUTM: ->
    qsObj = @properties.location.query_string
    @utm =
      source: qsObj.utm_source
      medium: qsObj.utm_medium
      campaign: qsObj.utm_campaign

  appendSources: (sources) ->
    $.extend(@sources, sources)

  setValueCallback: (callback) ->
    @getValue = callback if typeof callback is "function"

  getValue: () ->
    if @utm.medium? or @utm.campaign?
      if @utm.medium is "email"
        @sources.EMAIL
      else
        @sources.SEM

    else if @properties.engine?
      @sources.SEO

    else if @properties.referer != ""
      if @properties.isSocial()
        @sources.SOCIAL
      else
        @sources.REFERRAL

    else if @properties.referer is ""
      @sources.DIRECT
    else
      undefined

  append: ->
    if @registerSouce()
      value = @getValue()
      @writeFirstTouch(value)
      @writeLastTouch(value)
      @writeSource(value)

  registerSouce: ->
    !@properties.isInternal()

  writeFirstTouch: (value)->
    prop = {}
    prop[@firstSourceProperty] = value
    mixpanel.register(prop, @expirationDays) unless mixpanel.get_property(@firstSourceProperty)

  writeLastTouch: (value)->
    prop = {}
    prop[@lastSourceProperty] = value
    mixpanel.register(prop)

  writeSource: (value)->
    source = mixpanel.get_property(@sourceProperty)
    if source
      if source[source.length-1] != value
        mixpanel.get_property(@sourceProperty).push(value)
    else
      prop = {}
      prop[@sourceProperty] = [value]
      mixpanel.register(prop)
