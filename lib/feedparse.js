(function() {
  var fetchFeedContent, interval, networkids, parseFeedContent, since;

  since = 0;

  networkids = {
    'Twitter': 'Twitter',
    'Facebook': 'Facebook',
    'RSS': 'RSS',
    'GooglePlus': 'Google+',
    'Foursquare': '4sq',
    'Instagram': 'Instagram',
    'Goodreads': 'Goodreads',
    'IMDB': 'IMDB',
    'AppNET': 'App.net',
    'EyeEm': 'EyeEm'
  };

  $(function() {
    $('.media').empty().isotope({
      itemSelector: '.feed',
      getSortData: {
        created: function(elem) {
          return parseInt(elem.data('created'));
        }
      },
      sortBy: 'created',
      sortAscending: false
    });
    fetchFeedContent();
    return interval(180000, function() {
      return fetchFeedContent();
    });
  });

  fetchFeedContent = function() {
    return $.ajax('/feed.json', {
      type: 'GET',
      dataType: 'json',
      success: parseFeedContent,
      data: {
        'since': since
      }
    });
  };

  parseFeedContent = function(data) {
    var entry, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      entry = data[_i];
      _results.push((function(entry) {
        var content, created, link;
        link = $('<a />');
        link.attr({
          'href': entry.source,
          'class': 'feed',
          'target': '_blank'
        });
        link.addClass(entry.network.toLowerCase());
        link.data('created', entry.created_s);
        content = $('<div class="content"></div>');
        content.html(entry.content);
        content.appendTo(link);
        created = $('<div class="source">');
        created.html('via ' + networkids[entry.network] + ' am ' + entry.created_at);
        created.appendTo(link);
        $('.media').isotope('insert', link);
        if (!(since > entry.created_s)) return since = entry.created_s;
      })(entry));
    }
    return _results;
  };

  interval = function(time, fkt) {
    return setInterval(fkt, time);
  };

}).call(this);
