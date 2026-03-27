#ifndef IP_ALGORITHMS_TPP
#define IP_ALGORITHMS_TPP

#include <algorithm>
#include <array>
#include <functional>
#include <type_traits>

#include "ip_address.h"
#include "ip_algorithms.h"

namespace {
// Функция для создания IP-адреса, который будет использоваться в качестве границы при поиске
// диапазона. Сначала заполняем все октеты заданным значением (0 для нижней границы и 255 для
// верхней), а затем заменяем первые N октетов на заданные значения.
template <typename... Octets>
IpAddress make_boundary_ip(IpAddress::Octet fill, Octets... octets) {
    static_assert(sizeof...(octets) >= 1 && sizeof...(octets) <= 4,
                  "find_ip_range expects from 1 to 4 octets");

    static_assert((std::is_convertible_v<Octets, IpAddress::Octet> && ...),
                  "all octets must be convertible to IpAddress::Octet");

    std::array<IpAddress::Octet, 4> bytes{ fill, fill, fill, fill };
    std::array<IpAddress::Octet, sizeof...(octets)> prefix{ static_cast<IpAddress::Octet>(
        octets)... };

    for (std::size_t i = 0; i < prefix.size(); ++i) {
        bytes[i] = prefix[i];
    }

    return IpAddress{ std::to_string(static_cast<unsigned>(bytes[0])) + "." +
                      std::to_string(static_cast<unsigned>(bytes[1])) + "." +
                      std::to_string(static_cast<unsigned>(bytes[2])) + "." +
                      std::to_string(static_cast<unsigned>(bytes[3])) };
}
}  // namespace

template <typename... Octets>
IpRange find_ip_range(const IpContainer& ip_pool, Octets... octets) {
    return find_ip_range(ip_pool.begin(),
                         ip_pool.end(),
                         { make_boundary_ip(static_cast<IpAddress::Octet>(255), octets...),
                           make_boundary_ip(static_cast<IpAddress::Octet>(0), octets...) });
}

#endif  // IP_ALGORITHMS_TPP
