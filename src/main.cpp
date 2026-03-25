#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
#include <chrono>

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

using SystemTime = std::chrono::time_point<std::chrono::system_clock>;

int main() {
    try {
        SystemTime start_time;
        SystemTime end_time;

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
            (void)ip;
            // std::cout << ip << '\n';
        }


        IpAddress::Octet findOctet = 217;
        std::cout << "findOctet=" << static_cast<int>(findOctet) << ":  ";
// -----------------------------------------------------------------------------------------------------        
        std::size_t count;
        start_time = std::chrono::system_clock::now();
        count= 0;
        for (const auto& ip : ip_pool) {
            if (ip.starts_with({ findOctet })) {
                // std::cout << ip << '\n';
            }
            count++;
        }
        end_time = std::chrono::system_clock::now();
        std::cout << "count=" << count << " "
                  << std::chrono::duration_cast<std::chrono::nanoseconds>(end_time - start_time).count() << " ns   ";
// -----------------------------------------------------------------------------------------------------
        // отсоритрован по убыванию, потэтому можно пройтись с конца
        start_time = std::chrono::system_clock::now();
        count = 0;
        std::vector<IpAddress>::reverse_iterator it; 
        for (auto it = ip_pool.rbegin(); it != ip_pool.rend(); ++it) {
            if (it->starts_with({ findOctet })) {
                // std::cout << *it << '\n';
            }
            count++;
            if (it->octets()[0] > findOctet) {
                break;
            }
        }
        end_time = std::chrono::system_clock::now();
        std::cout << "count=" << count << " " 
                  << std::chrono::duration_cast<std::chrono::nanoseconds>(end_time - start_time).count() << " ns   ";
// -----------------------------------------------------------------------------------------------------
        // можно поискать бинарным поиском, так как отсортирован по убыванию и найти диапазон
        start_time = std::chrono::system_clock::now();

        auto first = std::lower_bound(
            ip_pool.begin(),
            ip_pool.end(),
            findOctet,
            [](const IpAddress& ip, IpAddress::Octet value) {
                return ip.octets()[0] > value;
            }
        );

        auto last = std::upper_bound(
            first,
            ip_pool.end(),
            findOctet,
            [](IpAddress::Octet value, const IpAddress& ip) {
                return ip.octets()[0] < value;
            }
        );

        std::size_t matched = 0;
        for (auto it = first; it != last; ++it) {
            // std::cout << *it << '\n';
            ++matched;
        }
        end_time = std::chrono::system_clock::now();
        std::cout << std::chrono::duration_cast<std::chrono::nanoseconds>(end_time - start_time).count() << " ns\n";
// -----------------------------------------------------------------------------------------------------



        // Выводим IP-адреса, начинающиеся с 46.70
        for (const auto& ip : ip_pool) {
            if (ip.starts_with({ 46, 70 })) {
                // std::cout << ip << '\n';
            }
        }

        // Выводим IP-адреса, содержащие 46
        for (const auto& ip : ip_pool) {
            if (ip.contains(46)) {
                // std::cout << ip << '\n';
            }
        }
    } catch (const std::exception& ex) {
        std::cerr << ex.what() << '\n';
        return 1;
    }

    return 0;
}
