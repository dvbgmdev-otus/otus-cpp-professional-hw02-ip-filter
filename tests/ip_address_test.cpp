#include "ip_address.h"

#include <gtest/gtest.h>

#include <sstream>
#include <stdexcept>
#include <string>

namespace {

std::string toString(const IpAddress& ip) {
    std::ostringstream oss;
    oss << ip;
    return oss.str();
}

}  // namespace

TEST(IpAddressTest, ConstructsFromValidAddress) {
    EXPECT_NO_THROW({
        const IpAddress ip{ "192.168.0.1" };
        EXPECT_EQ(toString(ip), "192.168.0.1");
    });
}

TEST(IpAddressTest, ConstructsFromZeroAddress) {
    EXPECT_NO_THROW({
        const IpAddress ip{ "0.0.0.0" };
        EXPECT_EQ(toString(ip), "0.0.0.0");
    });
}

TEST(IpAddressTest, ConstructsFromBroadcastAddress) {
    EXPECT_NO_THROW({
        const IpAddress ip{ "255.255.255.255" };
        EXPECT_EQ(toString(ip), "255.255.255.255");
    });
}

TEST(IpAddressTest, ThrowsIfOctetCountIsTooSmall) {
    EXPECT_THROW({ const IpAddress ip{ "1.2.3" }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfOctetCountIsTooLarge) {
    EXPECT_THROW({ const IpAddress ip{ "1.2.3.4.5" }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfFirstOctetIsEmpty) {
    EXPECT_THROW({ const IpAddress ip{ ".2.3.4" }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfMiddleOctetIsEmpty) {
    EXPECT_THROW({ const IpAddress ip{ "1..3.4" }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfLastOctetIsEmpty) {
    EXPECT_THROW({ const IpAddress ip{ "1.2.3." }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfOctetIsNotANumber) {
    EXPECT_THROW({ const IpAddress ip{ "1.abc.3.4" }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfOctetIsNegative) {
    EXPECT_THROW({ const IpAddress ip{ "-1.2.3.4" }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfOctetIsGreaterThan255) {
    EXPECT_THROW({ const IpAddress ip{ "256.2.3.4" }; }, std::invalid_argument);
}

TEST(IpAddressTest, ThrowsIfInputIsEmpty) {
    EXPECT_THROW({ const IpAddress ip{ "" }; }, std::invalid_argument);
}
