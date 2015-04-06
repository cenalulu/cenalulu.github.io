#include <iostream>
#include <string>
#include <fenv.h>
using namespace std;

int main() {


    const float x=1.1;
    const float z=1.123;
    float y=x;
    for(int j=0;j<90000000;j++)
    {
        y*=x;
        y/=z;
        y+= 0;
        y-= 0;
    }


    return 0;
}
