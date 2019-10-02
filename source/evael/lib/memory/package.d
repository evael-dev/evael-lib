module evael.lib.memory;

import std.conv : emplace;
import std.experimental.allocator.mallocator;
import std.experimental.allocator.building_blocks.stats_collector;
import std.traits : isImplicitlyConvertible;

public
{
	import evael.lib.memory.no_gc_class;
}

debug
{
	alias CustomStatsCollector = StatsCollector!(Mallocator, 
		Options.all, // Global stats
		Options.all  // Per call stats
	);

	__gshared CustomStatsCollector defaultAllocator;

	static ~this()
	{
		import std.stdio : writeln;
		if (defaultAllocator.bytesUsed != 0)
			writeln("StatsCollector: Bytes used by allocator != 0, you probably have a memory leak.");
	}
}
else
{
	__gshared Mallocator defaultAllocator;
}


/// From druntime. Used for Delete.
extern (C)
private void _d_monitordelete(Object h, bool det) @nogc nothrow pure;

@nogc
T New(T, Args...)(Args args, string file = __FILE__, int line =__LINE__) if (is(T == class))
{
	static if (!isImplicitlyConvertible!(T, NoGCClass))
	{
		static assert(false, "Your class must inerith from NoGCClass if you want to use New.");
	}

	enum size = __traits(classInstanceSize, T);

	auto memory = defaultAllocator.allocate(size);
	(cast(void*) memory)[0..size] = typeid(T).initializer[];

	T ret = emplace!(T, Args)(memory, args);
	ret.instantiatedWithGC = false;

	return ret;
}

@nogc
void Delete(T)(ref T instance, string file = __FILE__, int line =__LINE__) if (is(T == class) || is(T == interface))
{
	debug import std.stdio;

	auto obj = cast(Object) instance;
	auto p = cast(void*) obj;

	/** rt_finalize part **/
	auto ppv = cast(void**) p;

	if (!p || !*ppv)
		return;

	immutable instantiatedWithGC = (cast(NoGCClass) instance).instantiatedWithGC;

	auto pc = cast(ClassInfo*) *ppv;

	auto c = *pc;
	do
	{
		if (c.destructor)
		{
			alias DtorType = void function(Object) @nogc;
			(cast(DtorType) c.destructor)(obj);
		}
	}
	while ((c = c.base) !is null);

	if (ppv[1]) // if monitor is not null
		_d_monitordelete(obj, true);
	
	/** end of rt_finalize **/

	auto support = p[0..typeid(obj).initializer.length];

	// We need to do this before calling deallocate
	*ppv = null;

	// If it's a NoGCClass or NoGCInterface, we check if it New!(xx) or new xx was used
	static if (isImplicitlyConvertible!(T, NoGCClass) || isImplicitlyConvertible!(T, NoGCInterface))
	{
		if (instantiatedWithGC == false)
		{
			defaultAllocator.deallocate(support);
		}
	}

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
void Delete(T)(ref T* instance, string file = __FILE__, int line =__LINE__) if (is(T == struct))
{
	static if (__traits(hasMember, T, "__xdtor"))
	{
		instance.__xdtor();
	}

	defaultAllocator.deallocate((cast(void*) instance)[0..T.sizeof]);
	instance = null;
}