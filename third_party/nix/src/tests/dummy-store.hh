#pragma once

#include "libstore/store-api.hh"

namespace nix::tests {

class DummyStore final : public Store {
 public:
  explicit DummyStore() : Store(Store::Params{}) {}

  std::string getUri() { return ""; }

  void queryPathInfoUncached(
      const Path& path,
      Callback<std::shared_ptr<ValidPathInfo>> callback) noexcept {}

  Path queryPathFromHashPart(const std::string& hashPart) { return ""; }

  Path addToStore(const std::string& name, const Path& srcPath,
                  bool recursive = true, HashType hashAlgo = htSHA256,
                  PathFilter& filter = defaultPathFilter,
                  RepairFlag repair = NoRepair) {
    return "/nix/store/g1w7hy3qg1w7hy3qg1w7hy3qg1w7hy3q-x";
  }

  Path addTextToStore(const std::string& name, const std::string& s,
                      const PathSet& references, RepairFlag repair = NoRepair) {
    return "/nix/store/g1w7hy3qg1w7hy3qg1w7hy3qg1w7hy3q-x";
  }

  void narFromPath(const Path& path, Sink& sink) {}

  BuildResult buildDerivation(const Path& drvPath, const BasicDerivation& drv,
                              BuildMode buildMode = bmNormal) {
    return BuildResult{};
  }

  void ensurePath(const Path& path) {}
};

}  // namespace nix::tests
