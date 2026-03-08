#include "ip_filter.h"

#include <gtest/gtest.h>

TEST(SplitTest, BasicSplit) {
    auto result = split("11.22.33.44", '.');

    ASSERT_EQ(result.size(), 4);

    EXPECT_EQ(result[0], "11");
    EXPECT_EQ(result[1], "22");
    EXPECT_EQ(result[2], "33");
    EXPECT_EQ(result[3], "44");
}
// ("", '.') -> [""]

TEST(SplitTest, EmptyString) {
    auto result = split("", '.');

    ASSERT_EQ(result.size(), 1);
    EXPECT_EQ(result[0], "");
}

// ("11.", '.') -> ["11", ""]
TEST(SplitTest, TrailingDelimiter) {
    auto result = split("11.", '.');

    ASSERT_EQ(result.size(), 2);
    EXPECT_EQ(result[0], "11");
    EXPECT_EQ(result[1], "");
}

// (".11", '.') -> ["", "11"]
TEST(SplitTest, LeadingDelimiter) {
    auto result = split(".11", '.');

    ASSERT_EQ(result.size(), 2);
    EXPECT_EQ(result[0], "");
    EXPECT_EQ(result[1], "11");
}