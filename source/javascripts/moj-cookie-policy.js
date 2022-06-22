var mojforms = mojforms || {};

mojforms.cookiepolicy = new (function() {
  var COOKIE_POLICY = "mojforms_cookies_policy";
  var ANALYTICS = "analytics";
  var ACCEPTED = "accepted";
  var REJECTED = "rejected";

  // Currently we only set a preference for a general 'analytics' within
  // the cookie policy value, so we're just checking for that and nothing
  // else (at time of writing).
  this.setCookieBannerOnPageLoad = function() {
    switch(preference(ANALYTICS)) {
      case ACCEPTED:
      case REJECTED:
           this.hideCookieBanner();
           break;

      default: this.showCookieBanner();
    }
  }

  this.accept = function() {
    setAnalyticsCookie(ACCEPTED);
    showBannerMessage(ACCEPTED);
    this.reload(); // Reload but this time with Analytics activated
  }

  this.reject = function() {
    setAnalyticsCookie(REJECTED);
    removeAnalytics();
    showBannerMessage(REJECTED);
  }

  this.showCookieBanner = function() {
    document.getElementById('govuk-cookie-banner').style.display = ""; // Reset to default
    showBannerMessage();
  }

  this.hideCookieBanner = function() {
    document.getElementById('govuk-cookie-banner').style.display = 'none';
  }

  this.analyticsAllowed = function() {
    return preference(ANALYTICS) == ACCEPTED;
  }

  /* Attempt to turn off/deny analytics based code and/or cookies
   * @ga (String) Google analytics ID
   **/
  this.rejectAnalytics = function(ga) {
    removeAnalyticsCookies();

    window.ga = function() { /* disabled */ }
    window.gtag = function() { /* disabled */ }
    window.GoogleAnalyticsObject = "";
    window.dataLayer = {};
    window['ga-disable-' + ga] = true;
  }


  function preference(name) {
    var preferences = mojforms.cookie.get(COOKIE_POLICY);
    return JSON.parse(preferences || "{}")[name];
  }

  function setAnalyticsCookie (value) {
    var preferences = mojforms.cookie.get(COOKIE_POLICY) || {};
    preferences[ANALYTICS] = value;
    updatePolicyCookie(JSON.stringify(preferences));
  }

  function updatePolicyCookie(value) {
    mojforms.cookie.set(COOKIE_POLICY, value, new Date(new Date().getTime() + 1000 * 60 * 60 * 24 * 365).toUTCString());
  }

  // Closes all Cookie Banner message leaving only
  // the chosen (argument name) one visible.
  function showBannerMessage (name) {
    var message;
    var messages = document.getElementsByClassName("govuk-cookie-banner__message");
    for(var i=0; i<messages.length; ++i) {
      messages[i].style.display = "none";
    }

    message = document.getElementById("govuk-cookie-banner-message" + (name ? ("-" + name) : ""));

    if(message) {
      message.style.display = ""; // Reset inline style
    }
  }

  /* Existing function pulled from fb-runner code
   * Does this  work?
   **/
  function removeAnalyticsCookies() {
/*
TEMPORARILY DISABLED DUE TO USE OF ES6 CAUSING ISSUE WITH BUILD
    const cookiePrefixes = ['_ga', '_gid', '_gat_gtag_', '_hj', '_utma', '_utmb', '_utmc', '_utmz'];
    for (const cookie of document.cookie.split(';')) {
      for (const cookiePrefix of cookiePrefixes) {
        const cookieName = cookie.split('=')[0].trim();
        if (cookieName.startsWith(cookiePrefix)) {
          mojforms.cookie.remove(cookieName);
        }
      }
    }
*/
  }
});
