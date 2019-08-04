module evael.containers.Array;

import evael.memory;

struct Array(T)
{
	private T[] m_array;

	@nogc
	public this(in size_t length)
	{
		import std.experimental.allocator;
		this.m_array = makeArray!T(defaultAllocator, length);
	}

	/**
	 * Index operator overload.
	 */
	pragma(inline, true)
	@nogc
	public auto opIndex(size_t i) nothrow
	{
		return this.m_array[i];
	}
	
	/**
	 * Index assignment support
	 */
	pragma(inline, true)
	@nogc
	public void opIndexAssign(T value, size_t i) nothrow
	{
		this.m_array[i] = value;
	}


	@nogc
	public ~this()
	{
		defaultAllocator.deallocate(this.m_array);
	}
}