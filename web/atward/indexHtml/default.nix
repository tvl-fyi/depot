{ depot, ... }:

depot.web.tvl.template {
  useUrls = true;
  title = "atward";
  content = ''
    <p>
      <b>atward</b> is <a href="https://tvl.fyi/">TVL's</a> search
      service. It can be configured as a browser search engine for easy
      access to TVL bugs, code reviews, code paths and more.
    </p>

    <h3>Setting up atward</h3>
    <p>
      To configure atward, add a search engine to your browser with the
      following search string:
      <pre>  https://at.tvl.fyi/?q=%s</pre>
      Consider setting a shortcut, for example <b>t</b> or <b>tvl</b>.
      You can now quickly access TVL resources by typing something
      like <kbd>t b/42</kbd> in your URL bar to get to the bug with ID
      42.
    </p>

    <h3>Supported queries</h3>
    <p>
      The following query types are supported in atward:
      <ul>
        <li><kbd>b/42</kbd> - access bugs with ID 42</li>
        <li><kbd>cl/3087</kbd> - access changelist with ID 3087</li>
        <li><kbd>//web/atward</kbd> - open the <b>//web/atward</b> path in TVLs monorepo</li>
      </ul>
    </p>

    <h3>Configuration</h3>
    <p>
      Some behaviour of atward can be configured by adding query
      parameters to the search string:
      <ul>
        <li><kbd>cs=true</kbd> - use Sourcegraph instead of cgit to view code</li>
      </ul>
    </p>
    <p>
      In some browsers (like Firefox) users can not edit query
      parameters for search engines. As an alternative configuration can
      be supplied via cookies with the same names as the configuration
      parameters.
    </p>
    <p>
      The form below can set this configuration:
      <form class="cheddar-callout cheddar-todo">
        <input type="checkbox"
               id="cs-setting"
               onchange="saveSetting(this, 'cs');"
               > Use Sourcegraph instead of cgit</input>
      </form>
    </p>
    <noscript>
      <p class="cheddar-callout cheddar-warning">
        The form above only works with Javascript enabled. Only a few
        lines of Javascript are used, and they are licensed under a
        free-software license (MIT).
      </p>
    </noscript>

    <h3>Source code</h3>
    <p>
      atward's source code lives
      at <a href="https://atward.tvl.fyi/?q=%2F%2Fweb%2Fatward">//web/atward</a>.
    </p>
    '';
  extraHead = ''
    <script>
      /* Initialise the state of all settings. */
      function loadSettings() {
          loadSetting(document.getElementById('cs-setting'), 'cs');
      }

      /* Initialise the state of a setting from a cookie. */
      function loadSetting(checkbox, name) {
          if (document.cookie.split(';').some(function(cookie) {
              return cookie.indexOf(`''${name}=true`) >= 0;
          })) {
              checkbox.checked = true;
          }
      }

      /* Persist the state of a checkbox in a cookie */
      function saveSetting(checkbox, name) {
          console.log(`setting atward parameter '''''${name}' to ''${checkbox.checked.toString()}`);
          document.cookie = `''${name}=''${checkbox.checked.toString()};`;
      }

      document.addEventListener('DOMContentLoaded', loadSettings);
    </script>
    <link rel="search" type="application/opensearchdescription+xml" title="TVL Search" href="https://at.tvl.fyi/opensearch.xml">
  '';
}
