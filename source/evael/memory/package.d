module evael.memory;

import std.experimental.allocator.mallocator : Mallocator;
import std.experimental.allocator.building_blocks.stats_collector;

alias DefaultAllocator = StatsCollector!(Mallocator, 
	Options.bytesAllocated | Options.bytesUsed, // Global stats
	Options.bytesAllocated | Options.bytesUsed  // Per call stats
);

DefaultAllocator defaultAllocator;

@nogc
T New(T, Args...)(Args args)
{
	import std.conv : emplace;

	auto size = GetSize!T();
	auto memory = defaultAllocator.allocate(size);

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

	instance.__dtor();
	defaultAllocator.deallocate((cast(void*) instance)[0..size]);

	instance = null;
}

@nogc
void Delete(T)(T instance)
{
	Delete(instance);
}

size_t GetSize(T)()
{
	static if (is(T == struct)) 
	{
		return T.sizeof;
	}
	else static if (is(T == class) )
	{
		return __traits(classInstanceSize, T);
	}

	static assert("Unsupported type.");
}