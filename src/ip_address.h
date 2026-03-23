#ifndef IP_ADDRESS_H
#define IP_ADDRESS_H

#include <array>
#include <cstdint>
#include <iosfwd>
#include <string>

class IpAddress {
public:
    using Octet = std::uint8_t;

    explicit IpAddress(const std::string& text);

    friend std::ostream& operator<<(std::ostream& os, const IpAddress& ip);

private:
    std::array<Octet, 4> m_octets{};
};

#endif  // IP_ADDRESS_H
