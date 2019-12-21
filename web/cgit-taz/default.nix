# This derivation configures a 'cgit' instance to serve repositories
# from a different source.
#
# In the first round this will just serve my GitHub repositories until
# I'm happy with the display.

{ pkgs, ... }:

with pkgs.third_party;

let
  # Patched version of cgit that builds repository URLs correctly
  # (since only one repository is served)
  monocgit = cgit.overrideAttrs(old: {
    patches = old.patches ++ [ ./cgit_depot_url.patch ];
  });

  cmarkFilter = writeShellScript "pulldown-cmark-filter.sh" ''
    exec ${pulldown-cmark}/bin/pulldown-cmark -TFSL
  '';

  cgitConfig = writeText "cgitrc" ''
    # Global configuration
    virtual-root=/
    enable-http-clone=1
    readme=:README.md
    about-filter=${cmarkFilter}
    source-filter=${monocgit}/lib/cgit/filters/syntax-highlighting.py
    enable-log-filecount=1
    enable-log-linecount=1
    enable-follow-links=1
    enable-blame=1
    mimetype-file=${mime-types}/etc/mime.types
    logo=/plain/fun/logo/depot-logo.png

    # Repository configuration
    repo.url=depot
    repo.path=/git/depot/.git
    repo.desc=tazjin's personal monorepo
    repo.owner=tazjin <mail@tazj.in>
    repo.clone-url=https://git.tazj.in ssh://source.developers.google.com:2022/p/tazjins-infrastructure/r/depot
    repo.enable-remote-branches=1
  '';

  thttpdConfig = writeText "thttpd.conf" ''
    port=8080
    dir=${monocgit}/cgit
    nochroot
    novhost
    logfile=/dev/stdout
    cgipat=**.cgi
  '';

  # Patched version of thttpd that serves cgit.cgi as the index and
  # sets the environment variable for pointing cgit at the correct
  # configuration.
  #
  # Things are done this way because recompilation of thttpd is much
  # faster than cgit and I don't want to wait long when iterating on
  # config.
  thttpdConfigPatch = writeText "thttpd_cgit_conf.patch" ''
    diff --git a/libhttpd.c b/libhttpd.c
    index c6b1622..eef4b73 100644
    --- a/libhttpd.c
    +++ b/libhttpd.c
    @@ -3055,4 +3055,6 @@ make_envp( httpd_conn* hc )

         envn = 0;
    +    // force cgit to load the correct configuration
    +    envp[envn++] = "CGIT_CONFIG=${cgitConfig}";
         envp[envn++] = build_env( "PATH=%s", CGI_PATH );
     #ifdef CGI_LD_LIBRARY_PATH
  '';
  thttpdCgit = thttpd.overrideAttrs(old: {
    patches = [ ./cgit_idx.patch thttpdConfigPatch ];
  });
in writeShellScriptBin "cgit-launch" ''
  exec ${thttpdCgit}/bin/thttpd -D -C ${thttpdConfig}
# ''
