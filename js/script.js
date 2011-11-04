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
  
  function number_format(number, decimals, dec_point, thousands_sep) {
      // http://kevin.vanzonneveld.net
      // + original by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)
      // + improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
      // + bugfix by: Michael White (http://crestidg.com)
      // + bugfix by: Benjamin Lupton
      // + bugfix by: Allan Jensen (http://www.winternet.no)
      // + revised by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)
      // * example 1: number_format(1234.5678, 2, '.', '');
      // * returns 1: 1234.57
      var n = number,
      c = isNaN(decimals = Math.abs(decimals)) ? 2: decimals;
      var d = dec_point == undefined ? ",": dec_point;
      var t = thousands_sep == undefined ? ".": thousands_sep,
      s = n < 0 ? "-": "";
      var i = parseInt(n = Math.abs( + n || 0).toFixed(c)) + "",
      j = (j = i.length) > 3 ? j % 3: 0;
      return s + (j ? i.substr(0, j) + t: "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
  }
  
  function formatFileSize(filesize) {
      if (filesize >= 1073741824) {
          filesize = number_format(filesize / 1073741824, 2, '.', '') + ' GB';
      } else {
          if (filesize >= 1048576) {
              filesize = number_format(filesize / 1048576, 2, '.', '') + ' MB';
          } else {
              if (filesize >= 1024) {
                  filesize = number_format(filesize / 1024, 0) + ' KB';
              } else {
                  filesize = number_format(filesize, 0) + ' bytes';
              };
          };
      };
      return filesize;
  };

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
    // Downloads
    gh("/repos/"+gh_user+"/"+gh_repo + "/downloads", function(downloads){
      var stable, dev;
      var stableVersion = '2.1.1';
      var stableReleased = 'April 26, 2006';
      var devVersion = '3.0.0-beta5';
      if(downloads) {
        $.each(downloads, function(index,download){
          var replacements = [ 'cocoaDialog-', 'cocoaDialog_', 'CocoaDialog-', '.dmg', '.tar.gz' ];
          download.version = download.name;
          $.each(replacements, function(index,replacement){
            download.version = download.version.replace(replacement, '');
          });
          if (stableVersion == download.version) {
            stable = download;
          }
          if (devVersion == download.version) {
            dev = download;
          }
          download.released = $.format.date(download.created_at.replace('T', ' '), "MMMM dd, yyyy");
          console.log(download);
        });
      }
      var stableDiv = $('.sidebar .download.stable');
      var devDiv = $('.sidebar .download.dev');
      if (!stable) {
        stableDiv.hide();
      }
      else {
        stableDiv.find('.version .value').text(stable.version);
        if (stableReleased) {
          stableDiv.find('.released .value').text(stableReleased);
        }
        else {
          stableDiv.find('.released .value').text(stable.released);
        }
        stableDiv.find('.downloadCount .value').text(stable.download_count);        
        stableDiv.find('a.button').attr('href', stable.html_url);
        stableDiv.find('a.button .size').text(formatFileSize(stable.size));
      }
      if (!dev) {
        devDiv.hide();
      }
      else {
        devDiv.find('.version .value').text(dev.version);
        devDiv.find('.released .value').text(dev.released);
        devDiv.find('.downloadCount .value').text(dev.download_count);
        devDiv.find('a.button').attr('href', dev.html_url);
        devDiv.find('a.button .size').text(formatFileSize(dev.size));
      }
    });
    
    // Watchers & Forks
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
