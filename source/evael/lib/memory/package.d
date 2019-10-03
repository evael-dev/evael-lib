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
		import std.stdio : writefln;
		if (defaultAllocator.bytesUsed != 0)
		{
			writefln("StatsCollector: There are still %d bytes used, you probably have a memory leak.",
				defaultAllocator.bytesUsed);
		}
	}
}
else
{
	__gshared Mallocator defaultAllocator;
}

/**
 * Static helper that provides @nogc new and delete.
 */
static class MemoryHelper
{
	/// From druntime. Used by MemoryHelper.dispose(...).
	extern (C)
	private void _d_monitordelete(Object h, bool det) @nogc nothrow pure;

	/** 
	 * @nogc new for classes.
	 * Only classes that inherit from NoGCClass can be allocated with this function.
	 */
	@nogc
	public static T create(T, Args...)(Args args, string file = __FILE__, int line =__LINE__) if (is(T == class))
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

	/** 
	 * @nogc delete for classes and interfaces.
	 *
	 * - If this function is called on classes that inherit from NoGCClass / NoGCInterface (and are instantiated with @nogc new),
	 * 	 this functon will free memory and call object's destructor.
	 *
	 * - If it is called on classes allocated with GC, only the destructor will be called.
	 */
	@nogc
	public static void dispose(T)(ref T instance, string file = __FILE__, int line =__LINE__) if (is(T == class) || is(T == interface))
	{
		if (instance is null)
			return;

		enum isNoGCClass = isImplicitlyConvertible!(T, NoGCClass) || isImplicitlyConvertible!(T, NoGCInterface);

		static if (isNoGCClass)
		{
			bool instantiatedWithGC = (cast(NoGCClass) instance).instantiatedWithGC;
		}

		auto support = MemoryHelper.finalize(instance);

		static if(isNoGCClass)
		{
			if (instantiatedWithGC == false && support !is null)
			{
				defaultAllocator.deallocate(support);
			}
		}

		instance = null;
	}

	/**
	 * Calls the destructor of an object. 
	 * This code has been taken from the druntime repository.
	 */
	@nogc
	private static void[] finalize(T)(ref T instance)
	{
		auto obj = cast(Object) instance;
		auto p = cast(void*) obj;
		auto ppv = cast(void**) p;

		if (!p || !*ppv)
			return null;

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
		
		auto support = p[0..typeid(obj).initializer.length];

		*ppv = null;

		return support;
	}

	/**
	 * @nogc new for structs.
	 */
	@nogc
	public static T* create(T, Args...)(Args args, string file = __FILE__, int line =__LINE__) if (is(T == struct))
	{
		enum size = T.sizeof;

		auto memory = defaultAllocator.allocate(size);

		return emplace!(T, Args)(memory, args);
	}

	/**
	 * @nogc delete for structs.
	 */
	@nogc
	public static void dispose(T)(ref T* instance, string file = __FILE__, int line =__LINE__) if (is(T == struct))
	{
		destroy(instance);

		defaultAllocator.deallocate((cast(void*) instance)[0..T.sizeof]);
		instance = null;
	}

	/**
	 * @nogc delete for structs that have not been allocated with @nogc new.
	 */
	@nogc
	public static void dispose(T)(ref T instance, string file = __FILE__, int line =__LINE__) if (is(T == struct))
	{
		destroy(instance);
	}
}