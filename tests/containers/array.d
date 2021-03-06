module tests.containers.array;

import unit_threaded;
import evael.lib.containers.array;

@Name("Array is correctly initialized without capacity")
unittest
{
    auto arr = Array!int();

    arr.length.shouldEqual(0);
    arr.capacity.shouldEqual(0);
}

@Name("Array is correctly initialized with capacity")
unittest
{
    auto arr = Array!int(1337);

    arr.length.shouldEqual(0);
    arr.capacity.shouldEqual(1337);
}

@Name("Array access fails with invalid index")
unittest
{
    auto arr = Array!int(1337);

    arr[1].shouldThrow!Error();
}

@Name("Array access success with valid index")
unittest
{
    auto arr = Array!int(1337);
    arr.insert(50);

    arr[0].shouldEqual(50);
}

@Name("Array inserts value")
unittest
{
    auto arr = Array!int();
    arr.insert(50);
    
    arr[0].shouldEqual(50);
    arr.length.shouldEqual(1);
    arr.capacity.shouldEqual(32);
}

@Name("Array removes back value")
unittest
{
    auto arr = Array!int();
    arr.insert(50);
    arr.removeBack();
    
    arr[0].shouldThrow!Error();
    arr.length.shouldEqual(0);
    arr.capacity.shouldEqual(32);
}

@Name("Array removes value at specific index")
unittest
{
    auto arr = Array!int();
    arr.insert(50);
    arr.removeAt(0);
    
    arr[0].shouldThrow!Error();
    arr.length.shouldEqual(0);
    arr.capacity.shouldEqual(32);
}

@Name("Array removes value at invalid index")
unittest
{
    auto arr = Array!int();
    arr.insert(50);
    arr.removeAt(1).shouldThrow!Error();
}


@Name("Array index assignment")
unittest
{
    auto arr = Array!int();
    arr.insert(1);
    arr[0] = 50;

    arr[0].shouldEqual(50);
    arr.length.shouldEqual(1);
    arr.capacity.shouldEqual(32);
}

@Name("Array slice assignment")
unittest
{
    auto arr = Array!int(5, 1);
    arr[0..5] = 12345;

    for (int i = 0; i < arr.length; i++)
    {
        arr[i].shouldEqual(12345);
    }
}

@Name("Array slice assignment2")
unittest
{
    auto arr = Array!int(5, 1);
    arr[] = 1337;

    for (int i = 0; i < arr.length; i++)
    {
        arr[i].shouldEqual(1337);
    }
}

@Name("Array slice")
unittest
{
    auto arr = Array!int(5, 1);

    arr[].shouldEqual([1, 1, 1, 1, 1]);
}

@Name("Array slice2")
unittest
{
    auto arr = Array!int(5, 1);

    arr[0..5].shouldEqual([1, 1, 1, 1, 1]);
}

@Name("Array of array")
unittest
{
    auto arr = Array!(Array!bool)();

    arr.insert(Array!bool(3, false));

    arr[0][].shouldEqual([false, false, false]);
}

@Name("Array foreach loop")
unittest
{
    auto arr = Array!int(5, 1);

    int counter;

    foreach (i; arr)
    {
        counter++;
        i.shouldEqual(1);
    }

    counter.shouldEqual(arr.length);
}

@Name("Array foreach loop with index")
unittest
{
    auto arr = Array!int(5, 1);

    int counter;

    foreach (index, i; arr)
    {
        i.shouldEqual(1);
        index.shouldEqual(counter);
        counter++;
    }

    counter.shouldEqual(arr.length);
}