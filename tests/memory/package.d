module tests.memory;

import unit_threaded;
import evael.lib.memory;

@Setup
void setup()
{
    defaultAllocator = CustomStatsCollector();
}

@Name("New returns valid class")
unittest
{
    auto foo = New!Foo(1337);

    foo.shouldNotBeNull();
    foo.a.shouldEqual(1337);
}

@Name("Delete returns null object on class")
unittest
{
    auto foo = New!Foo(1337);
    Delete(foo);

    foo.shouldBeNull();
}

@Name("Delete returns null object on interface")
unittest
{
    IFoo foo = New!Foo(1337);
    Delete(foo);

    foo.shouldBeNull();
}

@Name("New allocates bytes")
unittest 
{
    auto foo = New!Foo(1337);

    defaultAllocator.bytesUsed.shouldEqual(__traits(classInstanceSize, Foo));
    defaultAllocator.bytesAllocated.shouldEqual(defaultAllocator.bytesUsed);
}

@Name("Delete deallocates bytes")
unittest 
{
    auto foo = New!Foo(1337);
    Delete(foo);

    defaultAllocator.numAllocate.shouldEqual(1);
    defaultAllocator.bytesUsed.shouldEqual(0);
}

@Name("Delete deallocates bytes when interface is passed as param")
unittest 
{
    IFoo foo = New!Foo(1337);
    Delete(foo);

    defaultAllocator.numAllocate.shouldEqual(1);
    defaultAllocator.bytesUsed.shouldEqual(0);
}

/**
 * Fixtures
 */
interface IFoo : NoGCInterface
{

}

class Foo : NoGCClass, IFoo
{
    public int a;
    public bool b;

    @nogc
    public this(int a)
    {
        this.a = a;
    }
}