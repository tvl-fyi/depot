#include "libutil/hash.hh"

#include <gtest/gtest.h>

class HashTest : public ::testing::Test {};

namespace nix {

TEST(HASH_TEST, SHA256) {
  auto hash = hashString(HashType::htSHA256, "foo");
  ASSERT_EQ(hash.base64Len(), 44);
  ASSERT_EQ(hash.base32Len(), 52);
  ASSERT_EQ(hash.base16Len(), 64);

  ASSERT_EQ(hash.to_string(Base16),
            "sha256:"
            "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae");
  ASSERT_EQ(hash.to_string(Base32),
            "sha256:1bp7cri8hplaz6hbz0v4f0nl44rl84q1sg25kgwqzipzd1mv89ic");
  ASSERT_EQ(hash.to_string(Base64),
            "sha256:LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564=");
}

}  // namespace nix
