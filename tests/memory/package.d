module tests.memory;

import unit_threaded;
import evael.memory;

@Name("New returns valid object")
unittest
{
    auto foo = New!Foo(1337);

    assert(foo);
    foo.a.shouldEqual(1337);
}

@Name("Delete returns null objectt")
unittest
{
    auto foo = New!Foo(1337);
    foo.Delete();

    assert(foo is null);
}

@Name("New allocates bytes")
unittest 
{
    defaultAllocator = CustomStatsCollector();

    auto foo = New!Foo(1337);

    defaultAllocator.bytesUsed.shouldEqual(GetSize!Foo());
    defaultAllocator.bytesAllocated.shouldEqual(defaultAllocator.bytesUsed);
}

@Name("Delete deallocates bytes")
unittest 
{
    defaultAllocator = CustomStatsCollector();

    auto foo = New!Foo(1337);
    foo.Delete();

    defaultAllocator.numAllocate.shouldEqual(1);
    defaultAllocator.bytesUsed.shouldEqual(0);
    defaultAllocator.bytesAllocated.shouldEqual( GetSize!Foo());
}


@Name("GetSize returns valid value")
unittest 
{
    // 8 + 8 + int + bool
    GetSize!Foo().shouldEqual(16 + int.sizeof + bool.sizeof);
}

/**
 * Fixtures
 */
class Foo
{
    public int a;
    public bool b;

    @nogc
    public this(int a)
    {
        this.a = a;
    }
}