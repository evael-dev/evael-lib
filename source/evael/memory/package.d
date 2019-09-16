module evael.memory;

import std.experimental.allocator.mallocator;
import std.experimental.allocator.building_blocks.stats_collector;

debug
{
    alias CustomStatsCollector = StatsCollector!(Mallocator, 
        Options.bytesAllocated | Options.bytesUsed | Options.numAllocate | Options.numDeallocate, // Global stats
        Options.bytesAllocated | Options.bytesUsed | Options.numAllocate | Options.numDeallocate  // Per call stats
    );

    CustomStatsCollector defaultAllocator;
}
else
{
    shared Mallocator defaultAllocator;
}

/**
 *
 */
@nogc
auto New(T, Args...)(Args args) if (is(T == class))
{
    import std.conv : emplace;

    immutable bytes = GetSize!T();
    
    auto memory = defaultAllocator.allocate(bytes);
    if (memory == null)
    {
        import core.exception : onOutOfMemoryError;
        onOutOfMemoryError();
    }

    return emplace!(T, Args)(memory, args);
}

@nogc
void Delete(T)(ref T instance)
{
    auto size = GetSize!T();

    static if (__traits(hasMember, T, "__xdtor"))
    {
        instance.__xdtor();
    }

    defaultAllocator.deallocate((cast(void*) instance)[0..size]);
    instance = null;
}

@nogc
void Delete(T)(T instance)
{
    Delete(instance);
}


/**
 * Returns size of T.
 */
size_t GetSize(T)()
{
    static if (is(T == struct)) 
    {
        return T.sizeof;
    }
    else static if (is(T == class) || is(T == interface))
    {
        return __traits(classInstanceSize, T);
    }

    static assert("Unsupported type.");
}