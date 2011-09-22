// script.js
(function($){
  var origContent = "";

  function loadContent(hash) {
    if(hash != "") {
      if(origContent == "") {
        origContent = $('#content').html();
      }
      $.get(hash +".html", function(html) {
        $('#content').html(html);
      }, 'html');
    }
    else if(origContent != "") {
      $('#content').html(origContent);
    }
  }

  $(document).ready(function() {
    $.history.init(loadContent);
    var links = $('#navigation li');
    $('a', links).not('.external').click(function(e) {
      links.filter('.active').removeClass('active');
      $(this).parent().addClass('active');
      var url = $(this).attr('href');
      url = url.replace(/^.*#/, '');
      $.history.load(url);
      $('html, body').animate({ scrollTop: 0 }, 0);
      return false;
    });
  });
  
})(jQuery);
