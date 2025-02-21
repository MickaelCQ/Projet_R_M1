#include <iostream>
#include <math.h>

int cumprod(size_t* list)
{
    int out = 0;
    std::cout << sizeof(list) << std::endl;
    for (unsigned long i = 0; i < sizeof(list); i++)
    {
        std::cout << list[i];
        out += list[i];
    }

    return out;
}


int cummin(size_t* list1, size_t* list2)
{
    int n = std::max(sizeof(list1), sizeof(list2));
    int out = 0;

    for (int i = 0; i < n; i++)
    {
        out += std::min(sizeof(list1), sizeof(list2));
    }
    
    return out;
}

int* diff(size_t* list, int lag)
{
    size_t* out;
    for (unsigned long i = 0; i < sizeof(list); i++)
    {
    }
}

size_t* range(int value)
{
    size_t* out = new size_t[value];
    for (int i = 0; i < value; i++)
    {
        out[i] = i;
    }
    
    return out;
}

size_t* randomRange(int value)
{
    size_t* out = new size_t[value];
    for (int i = 0; i < value; i++)
    {
        out[i] = random();
    }
    return out;
}


int main()
{
    int value = 1000;
    size_t* list = new size_t[value];
    size_t* list2 = new size_t[value];
    std::cout << sizeof(list);
    list = range(value);
    list2 = randomRange(value);
    std::cout << cumprod(list) << std::endl;
    std::cout << cummin(list, list2) << std::endl;
    

    return 0;
}
