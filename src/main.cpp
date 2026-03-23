#include <iostream>

#include "ip_address.h"

int main() {
    const IpAddress ip{ "192.168.0.1" };
    std::cout << ip << '\n';

    return 0;
}
