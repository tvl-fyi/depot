#include "libproto/worker.grpc.pb.h"
#include "libproto/worker.pb.h"
#include "libstore/store-api.hh"

namespace nix::daemon {

using ::grpc::Status;
using ::nix::proto::StorePath;
using ::nix::proto::StorePaths;
using ::nix::proto::Worker;

class WorkerServiceImpl final : public Worker::Service {
 public:
  WorkerServiceImpl(nix::Store* store) : store_(store) {}

  Status IsValidPath(grpc::ServerContext* context, const StorePath* request,
                     nix::proto::IsValidPathResponse* response) override {
    const auto& path = request->path();
    store_->assertStorePath(path);
    response->set_is_valid(store_->isValidPath(path));

    return Status::OK;
  }

  Status HasSubstitutes(grpc::ServerContext* context, const StorePath* request,
                        nix::proto::HasSubstitutesResponse* response) override {
    const auto& path = request->path();
    store_->assertStorePath(path);
    PathSet res = store_->querySubstitutablePaths({path});
    response->set_has_substitutes(res.find(path) != res.end());

    return Status::OK;
  }

  Status QueryReferrers(grpc::ServerContext* context, const StorePath* request,
                        StorePaths* response) override {
    const auto& path = request->path();
    store_->assertStorePath(path);

    PathSet paths;
    store_->queryReferrers(path, paths);

    for (const auto& path : paths) {
      response->add_paths(path);
    }

    return Status::OK;
  }

  Status QueryValidDerivers(grpc::ServerContext* context,
                            const StorePath* request, StorePaths* response) {
    const auto& path = request->path();
    store_->assertStorePath(path);

    PathSet paths = store_->queryValidDerivers(path);

    for (const auto& path : paths) {
      response->add_paths(path);
    }

    return Status::OK;
  }

  Status QueryDerivationOutputs(grpc::ServerContext* context,
                                const StorePath* request,
                                StorePaths* response) override {
    const auto& path = request->path();
    store_->assertStorePath(path);

    PathSet paths = store_->queryDerivationOutputs(path);

    for (const auto& path : paths) {
      response->add_paths(path);
    }

    return Status::OK;
  }

  Status QueryMissing(grpc::ServerContext* context, const StorePaths* request,
                      nix::proto::QueryMissingResponse* response) override {
    std::set<Path> targets;
    for (auto& path : request->paths()) {
      targets.insert(path);
    }
    PathSet will_build;
    PathSet will_substitute;
    PathSet unknown;
    // TODO(grfn): Switch to concrete size type
    unsigned long long download_size;
    unsigned long long nar_size;

    store_->queryMissing(targets, will_build, will_substitute, unknown,
                         download_size, nar_size);
    for (auto& path : will_build) {
      response->add_will_build(path);
    }
    for (auto& path : will_substitute) {
      response->add_will_substitute(path);
    }
    for (auto& path : unknown) {
      response->add_unknown(path);
    }
    response->set_download_size(download_size);
    response->set_nar_size(nar_size);

    return Status::OK;
  };

 private:
  // TODO(tazjin): Who owns the store?
  nix::Store* store_;
};

}  // namespace nix::daemon
