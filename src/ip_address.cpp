#include "ip_address.h"

#include <ostream>
#include <stdexcept>
#include <string>

namespace {
int octetToInt(IpAddress::Octet octet) noexcept { return static_cast<int>(octet); }

IpAddress::Octet intToOctet(int value) {
    if (value < 0 || value > 255) {
        throw std::invalid_argument("IP octet out of range");
    }

    return static_cast<IpAddress::Octet>(value);
}

IpAddress::Octet strToOctet(const std::string& value) {
    if (value.empty()) {
        throw std::invalid_argument("IP octet is empty");
    }

    std::size_t pos = 0;
    const int parsed = std::stoi(value, &pos);

    if (pos != value.size()) {
        throw std::invalid_argument("IP octet contains invalid characters");
    }

    return intToOctet(parsed);
}
}  // namespace

IpAddress::IpAddress(const std::string& text) {
    std::size_t start = 0;

    for (std::size_t i = 0; i < m_octets.size(); ++i) {
        if (i < m_octets.size() - 1) {
            const std::size_t end = text.find('.', start);
            if (end == std::string::npos) {
                throw std::invalid_argument("IP address must contain exactly 4 octets");
            }

            const std::string part = text.substr(start, end - start);
            m_octets[i] = strToOctet(part);
            start = end + 1;
        } else {
            const std::string part = text.substr(start);
            m_octets[i] = strToOctet(part);
        }
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
