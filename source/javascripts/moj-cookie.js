var moj = moj || {};

moj.cookie = new (function() {

  this.set = function(name, value, expiry) {
    var expires = "";
    if(expiry) {
      expires = "; expires=" + expiry;
    }
    document.cookie = name + "=" + value + expires + "; path=/";
  }

  this.get = function(name) {
    var cookie = null;
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');

    for(var i=0; i < ca.length; ++i) {
      var c = ca[i].trim();
      if(c.indexOf(nameEQ) == 0) {
        cookie = c.substring(nameEQ.length, c.length);
      }
    }

    return cookie;
  }

  this.remove = function(name) {
    this.set(name, "", -1);
  }
});
