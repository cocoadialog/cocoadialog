// script.js
(function($){
  var origContent = "";
  var origLink = null;
  var currentPage = null;
  
  function pageSections(content) {
    var content = $(content);
    var sidebar = $('#center .sidebar');
    var sidebarSections = $('.sections', sidebar);
    var sections = $('.sections', content).hide().clone().show();
    if (sidebarSections.length) {
      sidebarSections.remove();
    }
    if (sections.length) {
      sidebar.append(sections);
      var top = sections.offset().top - parseFloat(sections.css('marginTop').replace(/auto/, 0));
      $(window).scroll(function (event) {
        var y = $(this).scrollTop() + 140;
        if (y >= top) {
          sections.addClass('fixed');
        } else {
          sections.removeClass('fixed');
        }
      });
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
      if (hash != currentPage) {
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
          currentPage = hash;
        }, 'html');
      }
      else {
        scrollToHash(array);
      }
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
    
    $('.minibutton, .button').bind({
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
    
    function gh(url,callback) {
      $.getJSON("https://api.github.com"+url+"?callback=?", function(json){
        callback(json.data);
      });

    }
    var gh_user="mstratman";
    var gh_repo="cocoadialog";
    var gh_url = "https://github.com/"+gh_user+"/"+gh_repo;
    gh("/repos/"+gh_user+"/"+gh_repo, function(json){
      if(json) {
        $('.stats .watchers .value').html($('<a>').addClass('watchers').attr('href', gh_url+'/watchers').text(json.watchers));
        $('.stats .forks .value').html($('<a>').addClass('forks').attr('href', gh_url+'/network').text(json.forks));
      }
    });
    
    // Navigation Stats
    $('#navigation .stats div').each(function(){
      var stat = $(this).tipsy({gravity: 's'});
      var link;
      stat.mouseenter(function(){
        stat.addClass('hover');
        link = stat.find('a').click(function(){
          stat.trigger('click');
          return false;
        });
      }).mouseleave(function(){
        stat.removeClass('hover');
      }).click(function(){
        window.open(link.attr('href'),stat.attr('title'));
      });
    });
    
  });
  
})(jQuery);
