#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

#include "ip_address.h"

// Функция для разделения строки на части по заданному разделителю
std::vector<std::string> split(const std::string& str, char d) {
    std::vector<std::string> r;

    std::string::size_type start = 0;
    std::string::size_type stop = str.find_first_of(d);
    while (stop != std::string::npos) {
        r.push_back(str.substr(start, stop - start));

        start = stop + 1;
        stop = str.find_first_of(d, start);
    }

    r.push_back(str.substr(start));

    return r;
}

int main() {
    try {
        std::vector<IpAddress> ip_pool;
        std::string line;

        // Читаем IP-адреса из стандартного потока ввода, пока не достигнем конца потока
        while (std::getline(std::cin, line)) {
            const auto fields = split(line, '\t');
            if (fields.empty()) {
                continue;
            }

            ip_pool.emplace_back(fields.at(0));
        }

        // Сортируем IP-адреса в порядке убывания
        std::sort(ip_pool.begin(), ip_pool.end(), std::greater<IpAddress>{});

        // Выводим отсортированные IP-адреса
        for (const auto& ip : ip_pool) {
            std::cout << ip << '\n';
        }

        // Выводим IP-адреса, начинающиеся с 1
        for (const auto& ip : ip_pool) {
            if (ip.starts_with({ 1 })) {
                std::cout << ip << '\n';
            }
        }

        // Выводим IP-адреса, начинающиеся с 46.70
        for (const auto& ip : ip_pool) {
            if (ip.starts_with({ 46, 70 })) {
                std::cout << ip << '\n';
            }
        }

        // Выводим IP-адреса, содержащие 46
        for (const auto& ip : ip_pool) {
            if (ip.contains(46)) {
                std::cout << ip << '\n';
            }
        }
    } catch (const std::exception& ex) {
        std::cerr << ex.what() << '\n';
        return 1;
    }

    return 0;
}
