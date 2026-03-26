#include "ip_algorithms.h"

#include <algorithm>
#include <functional>

IpRange find_ip_range(IpIter first, IpIter last, const IpRangeFilter& range) {
    auto range_first = std::lower_bound(first, last, range.high, std::greater<IpAddress>{});
    auto range_last = std::upper_bound(range_first, last, range.low, std::greater<IpAddress>{});
    return { range_first, range_last };
}
