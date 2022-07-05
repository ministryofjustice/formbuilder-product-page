var mojforms = mojforms || {};

/* ----------------------------------------------------------------------------------------
 * Controlling Cookie:
 *   mojforms_cookies_policy
 *
 * Format:
 *   {
 *     analytics: true | false
 *   }
 * 
 * Format of cookie is based on that used by GDS Design System.
 * Allows for extensible/granular choices, if such a requirement will be required in future.
 * 
 * -----------------------------------------------------------------------------------------
 **/

mojforms.cookiepolicy = new (function() {
  var COOKIE_POLICY = "mojforms_cookies_policy";
  var ANALYTICS = "analytics";
  var ACCEPTED = "accepted";
  var REJECTED = "rejected";
  var COOKIE_BANNER_ID = "govuk-cookie-banner";
  var COOKIE_BANNER_MESSAGE_CLASSNAME = "govuk-cookie-banner__message";
  var COOKIE_BANNER_MESSAGE_ID = "govuk-cookie-banner-message";

  this.toggleBannerVisibility = function() {
    if(cookieExists()) {
      this.hideCookieBanner();
    }
    else {
      this.showCookieBanner();
    }
  }

  this.accept = function() {
    setPolicyCookie(ANALYTICS, true);
    showBannerMessage(ACCEPTED);
    mojforms.analytics.add();
  }

  this.reject = function() {
    setPolicyCookie(ANALYTICS, false);
    showBannerMessage(REJECTED);
    mojforms.analytics.remove();
  }

  this.showCookieBanner = function() {
    document.getElementById(COOKIE_BANNER_ID).style.display = ""; // Reset to default
    showBannerMessage();
  }

  this.hideCookieBanner = function() {
    document.getElementById(COOKIE_BANNER_ID).style.display = 'none';
  }

  this.analytics = function () {
    return preference(ANALYTICS);
  }

  /* Returns true is the Cookie Policy cookie has value.
   **/
  function cookieExists() {
    return mojforms.cookie.get(COOKIE_POLICY);
  }

  /* Returns true/false depending on inner conditions.
   * Initially set as evaluating Analytics preference only but
   * can be extended should more granular approach be required.
   **/
  function hasSetPreference() {
    var hasSetAnalyticsPreference = preference(ANALYTICS) != {};
    return hasSetAnalyticsPreference;
  }

  /* Returns preference value, if found or blank object.
   * @name (String) Name of set preference value to return.
   **/
  function preference(name) {
    var preferences = mojforms.cookie.get(COOKIE_POLICY);
    return JSON.parse(preferences || "{}")[name];
  }

  /* Sets the Cookie policy value (e.g. analytics:true) as key/value
   * of the Cookie Policy stored cookie preferences.
   **/
  function setPolicyCookie(name, value) {
    var preferences = mojforms.cookie.get(COOKIE_POLICY) || {};
    preferences[name] = value;
    mojforms.cookie.set(COOKIE_POLICY, JSON.stringify(preferences), new Date(new Date().getTime() + 1000 * 60 * 60 * 24 * 365).toUTCString());
  }

  /* Closes all Cookie Banner message leaving only
   * the chosen (argument name) one visible.
   *
   * [@name (String)] Trailing part of element ID to be exposed.
   *
   * Note: No argument will mean the default message will show. 
   **/
  function showBannerMessage (name) {
    var message;
    var messages = document.getElementsByClassName(COOKIE_BANNER_MESSAGE_CLASSNAME);
    for(var i=0; i<messages.length; ++i) {
      messages[i].style.display = "none";
    }

    message = document.getElementById(COOKIE_BANNER_MESSAGE_ID + (name ? ("-" + name) : ""));

    if(message) {
      message.style.display = ""; // Reset inline style
    }
  }

});
