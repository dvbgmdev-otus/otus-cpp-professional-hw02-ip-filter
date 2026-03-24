#ifndef IP_ADDRESS_H
#define IP_ADDRESS_H

#include <array>
#include <cstdint>
#include <iosfwd>
#include <string>

class IpAddress {
public:
    using Octet = std::uint8_t;
    using Octets = std::array<Octet, 4>;

    explicit IpAddress(const std::string& text);

    const Octets& octets() const noexcept;

    bool starts_with(std::initializer_list<Octet> prefix) const noexcept;
    bool contains(Octet value) const noexcept;

private:
    Octets m_octets{};
};

bool operator==(const IpAddress& lhs, const IpAddress& rhs) noexcept;
bool operator!=(const IpAddress& lhs, const IpAddress& rhs) noexcept;
bool operator<(const IpAddress& lhs, const IpAddress& rhs) noexcept;
bool operator>(const IpAddress& lhs, const IpAddress& rhs) noexcept;
bool operator<=(const IpAddress& lhs, const IpAddress& rhs) noexcept;
bool operator>=(const IpAddress& lhs, const IpAddress& rhs) noexcept;

std::ostream& operator<<(std::ostream& os, const IpAddress& ip);

#endif  // IP_ADDRESS_H
