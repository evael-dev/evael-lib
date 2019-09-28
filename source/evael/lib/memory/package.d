module evael.lib.memory;

import std.conv : emplace;
import std.experimental.allocator : make, dispose;
import std.experimental.allocator.mallocator;
import std.experimental.allocator.building_blocks.stats_collector;

debug
{
    alias CustomStatsCollector = StatsCollector!(Mallocator, 
        Options.all, // Global stats
        Options.all  // Per call stats
    );

    CustomStatsCollector defaultAllocator;
}
else
{
    shared Mallocator defaultAllocator;
}

@nogc
T New(T, Args...)(Args args, string file = __FILE__, int line =__LINE__) if (is(T == class))
{
     enum size = __traits(classInstanceSize, T);

     auto memory = defaultAllocator.allocate(size);
     (cast(void*) memory)[0..size] = typeid(T).initializer[];

     return emplace!(T, Args)(memory, args);
}

@nogc
void Delete(T)(ref T instance, string file = __FILE__, int line =__LINE__) if (is(T == class) || is(T == interface))
{
    auto obj = cast(Object) instance;
    auto support = (cast(void*) obj)[0..typeid(obj).initializer.length];

    static if (__traits(hasMember, T, "__xdtor"))
    {
        instance.__xdtor();
    }

    defaultAllocator.deallocate(support);
    instance = null;
}

@nogc
T* New(T, Args...)(Args args, string file = __FILE__, int line =__LINE__) if (is(T == struct))
{
     enum size = T.sizeof;

     auto memory = defaultAllocator.allocate(size);

     return emplace!(T, Args)(memory, args);
}

@nogc
void Delete(T)(T* instance, string file = __FILE__, int line =__LINE__) if (is(T == struct))
{
    static if (__traits(hasMember, T, "__xdtor"))
    {
        instance.__xdtor();
    }

    defaultAllocator.deallocate((cast(void*) instance)[0..T.sizeof]);
    instance = null;
}