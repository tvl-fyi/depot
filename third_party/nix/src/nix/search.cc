#include <fstream>
#include <regex>

#include <glog/logging.h>

#include "libexpr/eval-inline.hh"
#include "libexpr/eval.hh"
#include "libexpr/get-drvs.hh"
#include "libexpr/json-to-value.hh"
#include "libexpr/names.hh"
#include "libmain/common-args.hh"
#include "libmain/shared.hh"
#include "libstore/globals.hh"
#include "libutil/json.hh"
#include "nix/command.hh"

using namespace nix;

std::string wrap(const std::string& prefix, const std::string& s) {
  return prefix + s + ANSI_NORMAL;
}

std::string hilite(const std::string& s, const std::smatch& m,
                   const std::string& postfix) {
  return m.empty() ? s
                   : std::string(m.prefix()) + ANSI_RED + std::string(m.str()) +
                         postfix + std::string(m.suffix());
}

struct CmdSearch final : SourceExprCommand, MixJSON {
  std::vector<std::string> res;

  bool writeCache = true;
  bool useCache = true;

  CmdSearch() {
    expectArgs("regex", &res);

    mkFlag()
        .longName("update-cache")
        .shortName('u')
        .description("update the package search cache")
        .handler([&]() {
          writeCache = true;
          useCache = false;
        });

    mkFlag()
        .longName("no-cache")
        .description("do not use or update the package search cache")
        .handler([&]() {
          writeCache = false;
          useCache = false;
        });
  }

  std::string name() override { return "search"; }

  std::string description() override { return "query available packages"; }

  Examples examples() override {
    return {Example{"To show all available packages:", "nix search"},
            Example{"To show any packages containing 'blender' in its name or "
                    "description:",
                    "nix search blender"},
            Example{"To search for Firefox or Chromium:",
                    "nix search 'firefox|chromium'"},
            Example{"To search for git and frontend or gui:",
                    "nix search git 'frontend|gui'"}};
  }

  void run(ref<Store> store) override {
    settings.readOnlyMode = true;

    // Empty search string should match all packages
    // Use "^" here instead of ".*" due to differences in resulting highlighting
    // (see #1893 -- libc++ claims empty search string is not in POSIX grammar)
    if (res.empty()) {
      res.emplace_back("^");
    }

    std::vector<std::regex> regexes;
    regexes.reserve(res.size());

    for (auto& re : res) {
      regexes.emplace_back(re, std::regex::extended | std::regex::icase);
    }

    auto state = getEvalState();

    auto jsonOut = json ? std::make_unique<JSONObject>(std::cout) : nullptr;

    auto sToplevel = state->symbols.Create("_toplevel");
    auto sRecurse = state->symbols.Create("recurseForDerivations");

    bool fromCache = false;

    std::map<std::string, std::string> results;

    std::function<void(Value*, std::string, bool, JSONObject*)> doExpr;

    doExpr = [&](Value* v, const std::string& attrPath, bool toplevel,
                 JSONObject* cache) {
      DLOG(INFO) << "at attribute '" << attrPath << "'";

      try {
        uint found = 0;

        state->forceValue(*v);

        if (v->type == tLambda && toplevel) {
          Value* v2 = state->allocValue();
          state->autoCallFunction(*Bindings::NewGC(), *v, *v2);
          v = v2;
          state->forceValue(*v);
        }

        if (state->isDerivation(*v)) {
          DrvInfo drv(*state, attrPath, v->attrs);
          std::string description;
          std::smatch attrPathMatch;
          std::smatch descriptionMatch;
          std::smatch nameMatch;
          std::string name;

          DrvName parsed(drv.queryName());

          for (auto& regex : regexes) {
            std::regex_search(attrPath, attrPathMatch, regex);

            name = parsed.name;
            std::regex_search(name, nameMatch, regex);

            description = drv.queryMetaString("description");
            std::replace(description.begin(), description.end(), '\n', ' ');
            std::regex_search(description, descriptionMatch, regex);

            if (!attrPathMatch.empty() || !nameMatch.empty() ||
                !descriptionMatch.empty()) {
              found++;
            }
          }

          if (found == res.size()) {
            if (json) {
              auto jsonElem = jsonOut->object(attrPath);

              jsonElem.attr("pkgName", parsed.name);
              jsonElem.attr("version", parsed.version);
              jsonElem.attr("description", description);

            } else {
              auto name = hilite(parsed.name, nameMatch, "\e[0;2m") +
                          std::string(parsed.fullName, parsed.name.length());
              results[attrPath] = fmt(
                  "* %s (%s)\n  %s\n",
                  wrap("\e[0;1m", hilite(attrPath, attrPathMatch, "\e[0;1m")),
                  wrap("\e[0;2m", hilite(name, nameMatch, "\e[0;2m")),
                  hilite(description, descriptionMatch, ANSI_NORMAL));
            }
          }

          if (cache != nullptr) {
            cache->attr("type", "derivation");
            cache->attr("name", drv.queryName());
            cache->attr("system", drv.querySystem());
            if (!description.empty()) {
              auto meta(cache->object("meta"));
              meta.attr("description", description);
            }
          }
        }

        else if (v->type == tAttrs) {
          if (!toplevel) {
            auto attrs = v->attrs;
            Bindings::iterator j = attrs->find(sRecurse);
            if (j == attrs->end() ||
                !state->forceBool(*j->second.value, *j->second.pos)) {
              DLOG(INFO) << "skip attribute '" << attrPath << "'";
              return;
            }
          }

          bool toplevel2 = false;
          if (!fromCache) {
            Bindings::iterator j = v->attrs->find(sToplevel);
            toplevel2 = j != v->attrs->end() &&
                        state->forceBool(*j->second.value, *j->second.pos);
          }

          for (auto& i : *v->attrs) {
            auto cache2 =
                cache != nullptr
                    ? std::make_unique<JSONObject>(cache->object(i.second.name))
                    : nullptr;
            doExpr(i.second.value,
                   attrPath.empty()
                       ? std::string(i.second.name)
                       : attrPath + "." + std::string(i.second.name),
                   toplevel2 || fromCache, cache2 ? cache2.get() : nullptr);
          }
        }

      } catch (AssertionError& e) {
      } catch (Error& e) {
        if (!toplevel) {
          e.addPrefix(fmt("While evaluating the attribute '%s':\n", attrPath));
          throw;
        }
      }
    };

    Path jsonCacheFileName = getCacheDir() + "/nix/package-search.json";

    if (useCache && pathExists(jsonCacheFileName)) {
      LOG(WARNING) << "using cached results; pass '-u' to update the cache";

      Value vRoot;
      parseJSON(*state, readFile(jsonCacheFileName), vRoot);

      fromCache = true;

      doExpr(&vRoot, "", true, nullptr);
    }

    else {
      createDirs(dirOf(jsonCacheFileName));

      Path tmpFile = fmt("%s.tmp.%d", jsonCacheFileName, getpid());

      std::ofstream jsonCacheFile;

      try {
        // iostream considered harmful
        jsonCacheFile.exceptions(std::ofstream::failbit);
        jsonCacheFile.open(tmpFile);

        auto cache = writeCache
                         ? std::make_unique<JSONObject>(jsonCacheFile, false)
                         : nullptr;

        doExpr(getSourceExpr(*state), "", true, cache.get());

      } catch (std::exception&) {
        /* Fun fact: catching std::ios::failure does not work
           due to C++11 ABI shenanigans.
           https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66145 */
        if (!jsonCacheFile) {
          throw Error("error writing to %s", tmpFile);
        }
        throw;
      }

      if (writeCache &&
          rename(tmpFile.c_str(), jsonCacheFileName.c_str()) == -1) {
        throw SysError("cannot rename '%s' to '%s'", tmpFile,
                       jsonCacheFileName);
      }
    }

    if (results.empty()) {
      throw Error("no results for the given search term(s)!");
    }

    RunPager pager;
    for (const auto& el : results) {
      std::cout << el.second << "\n";
    }
  }
};

static RegisterCommand r1(make_ref<CmdSearch>());
