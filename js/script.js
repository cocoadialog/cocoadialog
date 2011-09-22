// script.js
(function($){
  var origContent = "";
  var origLink = null;
  
  function pageSections(content) {
    var content = $(content);
    var sidebar = $('#center .sidebar');
    var sidebarSections = $('.sections', sidebar);
    if (sidebarSections.length) {
      sidebarSections.remove();
    }
    var sections = $('.sections', content).hide().clone().show();
    if (sections.length) {
      sidebar.append(sections);
    }
    return content;
  }
  
  function scrollToHash(array) {
    var content = $('#content');
    // wait a bit for the new content to load
    setTimeout(function(){
      if (array.length == 2) {
        // Attempt to get an ID anchor
        var anchor = $('#' + array[1], content);
        // Attempt to get a named anchor
        if (!anchor.length) {
          anchor = $('[name="' + array[1] + '"]', content);
        }
        if (anchor.length) {
          $('html, body').animate({ scrollTop: anchor.offset().top }, 0);
        }
      }
      // Scroll to top for main page
      else {
        $('html, body').animate({ scrollTop: 0 }, 0);
      }
    }, 250);
  }
  
  function loadContent(hash) {
    var array = hash.split('/');
    hash = array[0];
    var content = $('#content');
    var links = $('#navigation li');
    if(hash != "") {
      if(origContent == "") {
        origLink = links.filter('.active');
        origContent = content.html();
      }
      var newLink = $('a', links).filter('[href="#' + hash + '"]').parent('li');
      if (newLink.length) {
        links.filter('.active').removeClass('active');
        newLink.addClass('active');
      }
      hash = hash.replace('!',''); //so the server doesn't balk at a URL containing !
      $.get(hash +".html", function(html) {
        content.html(html);
        pageSections(content);
        scrollToHash(array);
      }, 'html');
    }
    else if(origContent != "") {
      links.filter('.active').removeClass('active');
      origLink.addClass('active');
      content.html(origContent);
      pageSections(content);
      scrollToHash(array);
    }
    else {
      scrollToHash(array);
    }
  }

  $(document).ready(function() {
    pageSections($("#content"));
    $.history.init(loadContent);
    var links = $('#navigation li');
    $('a', links).not('.external').click(function(e) {
      // $(this).parent().addClass('active');
      var hash = $(this).attr('href');
      hash = hash.replace(/^.*#/, '');
      $.history.load(hash);
      return false;
    });
    
    $('a.minibutton').bind({
      mousedown: function() {
        $(this).addClass('mousedown');
      },
      blur: function() {
        $(this).removeClass('mousedown');
      },
      mouseup: function() {
        $(this).removeClass('mousedown');
      }
    });
    
  });
  
})(jQuery);
