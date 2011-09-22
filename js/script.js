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
  
  
  function loadContent(hash) {
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
      $.get(hash +".html", function(html) {
        content.html(html);
        pageSections(content);
      }, 'html');
    }
    else if(origContent != "") {
      links.filter('.active').removeClass('active');
      origLink.addClass('active');
      content.html(origContent);
      pageSections(content);
    }
  }

  $(document).ready(function() {
    pageSections($("#content"));
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
