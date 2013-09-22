since = 0

networkids = 
  'Twitter' : 'Twitter'
  'Facebook' : 'Facebook'
  'RSS' : 'RSS'
  'GooglePlus' : 'Google+'
  'Foursquare' : '4sq'
  'Instagram' : 'Instagram'
  'Goodreads' : 'Goodreads'
  'IMDB': 'IMDB'
  'AppNET': 'App.net'
  'EyeEm': 'EyeEm'

$ ->
  $('.media').empty().isotope
    itemSelector: '.feed',
    getSortData:
      created: (elem) ->
        return parseInt(elem.data 'created')
    sortBy: 'created',
    sortAscending: false
  fetchFeedContent()
  interval 180000, ->
    fetchFeedContent()

fetchFeedContent = () ->
  $.ajax '/feed.json',
    type: 'GET',
    dataType: 'json',
    success: parseFeedContent,
    data:
      'since': since

parseFeedContent = (data) ->
  for entry in data
    do (entry) ->
      link = $('<a />')
      link.attr
        'href' : entry.source,
        'class' : 'feed',
        'target' : '_blank'
      link.addClass entry.network.toLowerCase()
      link.data 'created', entry.created_s
      content = $('<div class="content"></div>')
      content.html(entry.content)
      content.appendTo link
      created = $('<div class="source">')
      created.html('via ' + networkids[entry.network] + ' am ' + entry.created_at)
      created.appendTo link
      #link.appendTo $('.media')
      $('.media').isotope('insert', link)
      since = entry.created_s unless since > entry.created_s
  
interval = (time, fkt) ->
  setInterval fkt, time
