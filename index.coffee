objectFromUrlParameters = (hash)->
  hashParameters = {}
  hash.split('&').forEach (keyValue)->
    [keyword,value] = keyValue.split '='
    hashParameters[keyword]=value
  return hashParameters

updateDropboxAuthentication = (accessToken)->
  $.ajax
    url:        'http://localhost:8000/api/beta/join'
    type:       'post'
    xhrFields:
      withCredentials: true
    headers:
      Authorization : "Bearer #{accessToken}"
  .then (data)->
    analytics.alias data.uid
    analytics.identify
      email         : _.get data, 'email'
      firstName     : _.get data, 'name_details.given_name'
      lastName      : _.get data, 'name_details.surname'
      name          : _.get data, 'name_details.familiar_name'
      country       : _.get data, 'country'
      locale        : _.get data, 'locale'
      dropbox_uid   : data.uid
      access_token  : accessToken
  .fail ->
    true
  .always ->
    updateVisibleSection()
  true

updateVisibleSection = ->
  traits = analytics.user().traits()
  visibleSection = if traits.access_token then '#user-signed-up-waiting'  else '#connect-to-dropbox'
  $(visibleSection).removeClass('hide').fadeIn()

bindUserTraits = ->
  traits = analytics.user().traits()
  _.forOwn traits, (value,key)-> $(".#{key}").text value

analytics.on 'identify', bindUserTraits

hashParameters = objectFromUrlParameters window.location.hash.substr 1
history.pushState(
  ""
  document.title
  window.location.pathname + window.location.search
)

if hashParameters.access_token
  updateDropboxAuthentication hashParameters.access_token
else
  analytics.ready ->
    analytics.user().load()
    bindUserTraits()
    updateVisibleSection()