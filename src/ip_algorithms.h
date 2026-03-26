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

IpRange find_ip_range(const IpContainer& ip_pool, IpAddress::Octet first_octet);

IpRange find_ip_range(const IpContainer& ip_pool,
                      IpAddress::Octet first_octet,
                      IpAddress::Octet second_octet);

#endif  // IP_ALGORITHMS_H
