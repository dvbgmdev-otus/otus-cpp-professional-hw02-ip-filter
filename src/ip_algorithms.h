#ifndef IP_ALGORITHMS_H
#define IP_ALGORITHMS_H

#include <vector>

#include "ip_address.h"

using IpContainer = std::vector<IpAddress>;
using IpIter = IpContainer::const_iterator;

struct IpRange {
    IpIter first;
    IpIter last;
};

struct IpRangeFilter {
    IpAddress high;
    IpAddress low;
};

IpRange find_ip_range(IpIter first, IpIter last, const IpRangeFilter& range);

#endif  // IP_ALGORITHMS_H
