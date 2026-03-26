#include "ip_address.h"

#include <ostream>
#include <stdexcept>
#include <string>

namespace {
int octetToInt(IpAddress::Octet octet) noexcept { return static_cast<int>(octet); }

IpAddress::Octet strToOctet(const std::string& value) {
    // Октет не должен быть пустым
    if (value.empty()) {
        throw std::invalid_argument("IP octet is empty");
    }

    // Октет должен состоять только из цифр
    for (char ch : value) {
        if (ch < '0' || ch > '9') {
            throw std::invalid_argument("IP octet contains invalid characters");
        }
    }

    // Октет не должен содержать ведущих нулей (кроме случая, когда октет равен "0")
    // думал удалять нули, но передумал - валидация должна проверять, но не исправлять
    if (value.size() > 1 && value.front() == '0') {
        throw std::invalid_argument("IP octet must not contain leading zeros");
    }

    // Октет не должен быть длиннее 3 символов, так как максимальное значение - 255
    if (value.size() > 3) {
        throw std::invalid_argument("IP octet out of range");
    }

    // Преобразуем строку в число и проверяем, что она не превышает 255
    int parsed = 0;
    for (char ch : value) {
        parsed = parsed * 10 + static_cast<int>(ch - '0');
    }
    if (parsed > 255) {
        throw std::invalid_argument("IP octet out of range");
    }

    return static_cast<IpAddress::Octet>(parsed);
}
}  // namespace

IpAddress::IpAddress(const std::string& text) {
    std::size_t start = 0;

    for (std::size_t i = 0; i < m_octets.size(); ++i) {
        const std::size_t end = text.find('.', start);

        if (i < m_octets.size() - 1) { // для первых 3 октетов
            if (end == std::string::npos) {
                throw std::invalid_argument("IP address must contain exactly 4 octets");
            }

            const std::string part = text.substr(start, end - start);
            m_octets[i] = strToOctet(part);
            start = end + 1;
        } else { // для последнего октета точек быть не должно
            if (end != std::string::npos) {
                throw std::invalid_argument("IP address must contain exactly 4 octets");
            }

            const std::string part = text.substr(start);
            m_octets[i] = strToOctet(part);
        }
    }
}

const IpAddress::Octets& IpAddress::octets() const noexcept {
    return m_octets;
}

bool IpAddress::contains(Octet value) const noexcept {
    for (const auto& octet : m_octets) {
        if (octet == value) {
            return true;
        }
    }
    return false;
}

bool operator==(const IpAddress& lhs, const IpAddress& rhs) noexcept {
    return lhs.octets() == rhs.octets();
}

bool operator!=(const IpAddress& lhs, const IpAddress& rhs) noexcept {
    return !(lhs == rhs);
}

bool operator<(const IpAddress& lhs, const IpAddress& rhs) noexcept {
    return lhs.octets() < rhs.octets();
}

bool operator>(const IpAddress& lhs, const IpAddress& rhs) noexcept {
    return rhs < lhs;
}

bool operator<=(const IpAddress& lhs, const IpAddress& rhs) noexcept {
    return !(rhs < lhs);
}

bool operator>=(const IpAddress& lhs, const IpAddress& rhs) noexcept {
    return !(lhs < rhs);
}

std::ostream& operator<<(std::ostream& os, const IpAddress& ip) {
    // clang-format off
    os << octetToInt(ip.octets()[0]) << '.'
       << octetToInt(ip.octets()[1]) << '.'
       << octetToInt(ip.octets()[2]) << '.'
       << octetToInt(ip.octets()[3]);
    // clang-format on

    return os;
}
