module tests.memory.no_gc_class;

import unit_threaded;
import evael.lib.memory;

@Setup
void setup()
{
    defaultAllocator = CustomStatsCollector();
}

@Name("New correctly sets `instantiatedWithGC = false` on class")
unittest
{
    auto foo = MemoryHelper.create!Foo(1337);

    foo.instantiatedWithGC.shouldEqual(false);
}

@Name("New correctly sets `instantiatedWithGC = true` on class")
unittest
{
    auto foo = new Foo(1337);

    foo.instantiatedWithGC.shouldEqual(true);
}

@Name("New correctly sets `instantiatedWithGC = false` on interface")
unittest
{
    IFoo foo = MemoryHelper.create!Foo(1337);
    (cast(NoGCClass) foo).instantiatedWithGC.shouldEqual(false);
}

@Name("New correctly sets `instantiatedWithGC = true` on interface")
unittest
{
    IFoo foo = new Foo(1337);
    (cast(NoGCClass) foo).instantiatedWithGC.shouldEqual(true);
}

@Name("Delete dont free memory of GC class`")
unittest
{
    auto foo = new Foo(1337);
    auto foo2 = foo;
    MemoryHelper.dispose(foo);
    foo.shouldBeNull();
    foo2.a.shouldEqual(1337);
}

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
