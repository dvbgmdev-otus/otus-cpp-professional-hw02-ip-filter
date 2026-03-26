#include "ip_algorithms.h"

#include <algorithm>
#include <functional>

#include "ip_address.h"

namespace {
// можно было сделать конструктор, но так как он нужен только в одном месте, то решил сделать
// функцию-helper
IpAddress make_ip(IpAddress::Octet a, IpAddress::Octet b, IpAddress::Octet c, IpAddress::Octet d) {
    return IpAddress(std::to_string(static_cast<unsigned>(a)) + "." +
                     std::to_string(static_cast<unsigned>(b)) + "." +
                     std::to_string(static_cast<unsigned>(c)) + "." +
                     std::to_string(static_cast<unsigned>(d)));
}

}  // namespace

// Универсальная функция для поиска диапазона IP-адресов, соответствующих заданному фильтру
IpRange find_ip_range(IpIter first, IpIter last, const IpRangeFilter& range) {
    auto range_first = std::lower_bound(first, last, range.high, std::greater<IpAddress>{});
    auto range_last = std::upper_bound(range_first, last, range.low, std::greater<IpAddress>{});
    return { range_first, range_last };
}

// Функция для поиска диапазона IP-адресов, начинающихся с заданного первого октета
IpRange find_ip_range(const IpContainer& ip_pool, IpAddress::Octet first_octet) {
    return find_ip_range(ip_pool.begin(),
                         ip_pool.end(),
                         { make_ip(first_octet, 255, 255, 255), make_ip(first_octet, 0, 0, 0) });
}

// Функция для поиска диапазона IP-адресов, начинающихся с заданных первого и второго октетов
IpRange find_ip_range(const IpContainer& ip_pool,
                      IpAddress::Octet first_octet,
                      IpAddress::Octet second_octet) {
    return find_ip_range(
        ip_pool.begin(),
        ip_pool.end(),
        { make_ip(first_octet, second_octet, 255, 255), make_ip(first_octet, second_octet, 0, 0) });
}