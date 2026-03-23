#include "ip_address.h"

#include <ostream>
#include <string>

namespace {
int octetToInt(IpAddress::Octet octet) noexcept { return static_cast<int>(octet); }
IpAddress::Octet intToOctet(int value) noexcept { return static_cast<IpAddress::Octet>(value); }
IpAddress::Octet strToOctet(const std::string& value) { return intToOctet(std::stoi(value)); }
}  // namespace

IpAddress::IpAddress(const std::string& text) {
    std::size_t start = 0;
    std::size_t end = 0;

    for (std::size_t i = 0; i < m_octets.size(); ++i) {
        end = text.find('.', start);

        const std::string part =
            (end == std::string::npos) ? text.substr(start) : text.substr(start, end - start);

        m_octets[i] = strToOctet(part);

        start = end + 1;
    }
}

std::ostream& operator<<(std::ostream& os, const IpAddress& ip) {
    // clang-format off
    os << octetToInt(ip.m_octets[0]) << '.'
       << octetToInt(ip.m_octets[1]) << '.'
       << octetToInt(ip.m_octets[2]) << '.'
       << octetToInt(ip.m_octets[3]);
    // clang-format on

    return os;
}
