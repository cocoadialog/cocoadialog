// script.js
(function($){
  var origContent = "";
  var origLink = null;
  function loadContent(hash) {
    var links = $('#navigation li');
    if(hash != "") {
      if(origContent == "") {
        origLink = links.filter('.active');
        origContent = $('#content').html();
      }
      links.filter('.active').removeClass('active');
      $('a', links).filter('[href="#' + hash + '"]').parent('li').addClass('active');
      $.get(hash +".html", function(html) {
        $('#content').html(html);
      }, 'html');
    }
    else if(origContent != "") {
      links.filter('.active').removeClass('active');
      origLink.addClass('active');
      $('#content').html(origContent);
    }
  }

  $(document).ready(function() {
    $.history.init(loadContent);
    var links = $('#navigation li');
    $('a', links).not('.external').click(function(e) {
      // $(this).parent().addClass('active');
      var url = $(this).attr('href');
      url = url.replace(/^.*#/, '');
      $.history.load(url);
      $('html, body').animate({ scrollTop: 0 }, 0);
      return false;
    });
  });
  
})(jQuery);
