#include <vector>
#include <iostream>

// OOB = out-of-nounds

void trigger_overflow() {
  std::vector<int> v = {1, 2, 3};
  std::cout << "Accessing OOB: " << v[3] << std::endl; 
}

int main() {
  std::cout << "Starting..." << std::endl;
  trigger_overflow();
  return 0;
}
