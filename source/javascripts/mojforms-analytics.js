var mojforms = mojforms || {};

mojforms.analytics = new (function() {

  this.add = function(ga_id) {
//    enableGogleAnalytics(ga_id);
    enableGoogleG4Analytics(ga_id);
  }

  this.remove = function(ga_id) {
    disableGoogleAnalytics(ga_id);
    removeAnalyticsCookies();
  }

  /* Attempt to turn on Google analytics based code.
   * @account (String) Google analytics ID
   **/
  function enableGogleAnalytics(account) {
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

    ga('create', account, 'auto');
    ga('set', 'anonymizeIp', true);
    ga('set', 'displayFeaturesTask', null);
    ga('set', 'transport', 'beacon');
    ga('send', 'pageview');
  }

  /* Experiment to get G4 analytics working
   **/
  function enableGoogleG4Analytics(account) {
    (function(i,s,o,g,r,a,m){
      i['dataLayer'] = i.dataLayer || [];
      i['gtag'] = function(){i.dataLayer.push(arguments);}
      a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g+r;m.parentNode.insertBefore(a,m);
    })(window, document, 'script', 'https://www.googletagmanager.com/gtag/js?id=', account);

    gtag('js', new Date());
    gtag('config', account);
/*
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-3FWVT6GV20"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-3FWVT6GV20');
</script>
*/
  }

  /* Attempt to turn off/deny Google analytics based code.
   * @account (String) Google analytics ID
   **/
  function disableGoogleAnalytics(account) {
    delete window.ga;
    delete window.gtag;
    delete window.GoogleAnalyticsObject;
    delete window.dataLayer;
    window['ga-disable-' + account] = true;
  }

  /* Existing function pulled from fb-runner code
   * Pulled from fb-runner code; Does this work?
   **/
  function removeAnalyticsCookies() {
    const cookiePrefixes = ['_ga', '_gid', '_gat_gtag_', '_hj', '_utma', '_utmb', '_utmc', '_utmz'];
    for (const cookie of document.cookie.split(';')) {
      for (const cookiePrefix of cookiePrefixes) {
        const cookieName = cookie.split('=')[0].trim();
        if (cookieName.startsWith(cookiePrefix)) {
          mojforms.cookie.remove(cookieName);
        }
      }
    }
  }

});
