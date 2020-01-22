module evael.lib.containers.array;

import std.experimental.allocator : makeArray, expandArray, shrinkArray;

public import evael.lib.memory;

/**
 * Simple dynamic array.
 */
struct Array(T)
{
    private T[] m_array;

    private size_t m_capacity;
    private size_t m_length;

    /**
     * Array constructor.
     * Creates an array.
     * Params:
     * 		capacity : capacity of the array
     */
    @nogc
    public this(in size_t capacity)
    {
        this.m_array = cast(T[]) defaultAllocator.allocate(T.sizeof * capacity);
        this.m_capacity = capacity;
    }

    /**
     * Array constructor.
     * Creates an array and fills it with data.
     * Params:
     * 		data : data that will be inserted
     */
    @nogc
    public this(T[] data)
    {
        this.m_capacity = data.length;
        this.m_length = data.length;
        this.m_array = cast(T[]) defaultAllocator.allocate(T.sizeof * capacity);
        this.m_array[] = data[];
    }

    /**
     * Array constructor.
     * Creates an array with a specific default value.
     * Params:
     * 		capacity : capacity of the array
     *		defaultValue : default value
     */
    @nogc
    public this(in size_t capacity, T defaultValue)
    {
        this.m_array = cast(T[]) defaultAllocator.allocate(T.sizeof * capacity);
        this.m_array[] = defaultValue;
        this.m_capacity = capacity;
        this.m_length = capacity;
    }		

    @nogc
    public void dispose()
    {
        if (this.m_array !is null)
        {
            defaultAllocator.deallocate(this.m_array);
            this.m_array = null;
        }
    }

    /**
     * Inserts element at the end of array.
     * Params:
     *		element : element to insert
     */
    @nogc
    public void insert(T element)
    {
        if (this.m_array is null)
        {
            this.m_array = cast(T[])defaultAllocator.allocate(T.sizeof * 32);
            this.m_capacity = 32;
        }
        else if (this.m_length >= this.m_array.length)
        {
            immutable delta = this.m_array.length > 512 ? 1024 : this.m_array.length << 1;
            
            if (!defaultAllocator.expandArray(this.m_array, delta))
            {
                this.m_capacity += delta;
                assert(0);
            }
        }

        this.m_array[this.m_length++] = element;
    }

    /**
     * Removes the item at the given index from the array.
     * Params:
     *		i : index
     */
    @nogc
    public void removeAt(in size_t i)
    in (i < this.m_length)
    {
        static if (is(T == class) || is(T == interface))
        {
            MemoryHelper.dispose(this.m_array[i]);
        }

        auto next = i + 1;

        while (next < this.m_length)
        {
            this.m_array[next - 1] = this.m_array[next];
            ++next;
        }

        this.m_length -= 1;
    }

    /**
     * Removes the last element from the array.
     */
    pragma(inline, true)
    @nogc
    public void removeBack()
    {
        this.removeAt(this.m_length - 1);
    }

    /**
     * Index operator overload.
     */
    pragma(inline, true)
    @nogc
    public ref T opIndex(size_t i)
    in (i < this.m_length)
    {
        return this.m_array[i];
    }
    
    /**
     * Index assignment support.
     */
    pragma(inline, true)
    @nogc
    public void opIndexAssign(T value)
    {
        opSliceAssign(value);
    }

    /**
     * Index assignment support.
     */
    pragma(inline, true)
    @nogc
    public void opIndexAssign(T value, size_t i)
    {
        opIndex(i) = value;
    }

    /**
     * Slice assignment support.
     */
    pragma(inline, true)
    @nogc
    public void opSliceAssign(T value)
    {
        this.m_array[0 .. this.m_length] = value;
    }

    pragma(inline, true)
    @nogc
    public void opSliceAssign(T[] values)
    {
        this.m_array[] = values[];
    }

    pragma(inline, true)
    @nogc
    public void opSliceAssign(T value, size_t i, size_t j)
    {
        this.m_array[i .. j] = value;
    }

    pragma(inline, true)
    @nogc
    public void opSliceAssign(T[] values, size_t i, size_t j)
    {
        this.m_array[i .. j] = values;
    }

    /**
     * Slice operator overload.
     */
    pragma(inline, true)
    @nogc
    public T[] opSlice()
    {
        return opSlice(0, this.m_length);
    }

    pragma(inline, true)
    @nogc
    public T[] opSlice(size_t a, size_t b)
    {
        return this.m_array[a .. b];
    }

    /**
     * @nogc foreach(i, j) support.
     */
    @nogc
    public int opApply(scope int delegate(size_t i, ref T) @nogc operation)
    {
        return opApplyIndexImpl(operation);
    }

    @nogc
    public int opApply(scope int delegate(size_t i, ref T) @nogc nothrow operation) nothrow
    {
        return opApplyIndexImpl(operation);
    }

    @nogc
    public int opApply(scope int delegate(size_t i, ref const(T)) @nogc operation) const
    {
        return opApplyIndexImpl(operation);
    }

    @nogc
    public int opApply(scope int delegate(size_t i, ref const(T)) @nogc nothrow operation) const nothrow
    {
        return opApplyIndexImpl(operation);
    }

    /**
     * @nogc foreach(i) support.
     */
    @nogc
    public int opApply(scope int delegate(ref T) @nogc operation)
    {
        return opApplyImpl(operation);
    }

    @nogc
    public int opApply(scope int delegate(ref T) @nogc nothrow operation) nothrow
    {
        return opApplyImpl(operation);
    }

    @nogc
    public int opApply(scope int delegate(ref const(T)) @nogc operation) const
    {
        return opApplyImpl(operation);
    }

    @nogc
    public int opApply(scope int delegate(ref const(T)) @nogc nothrow operation) const nothrow
    {
        return opApplyImpl(operation);
    }

    /**
     * foreach support.
     */
    public int opApply(scope int delegate(size_t i, ref T) operation)
    {
        return opApplyIndexImpl(operation);
    }

    public int opApply(scope int delegate(ref T) operation)
    {
        return opApplyImpl(operation);
    }

    public int opApplyIndexImpl(O)(O operation)
    {
        int result;

        foreach (i, ref v; this.m_array[0..this.m_length])
        {
            result = operation(i, v);

            if (result)
            {
                break;
            }
        }

        return result;
    }

    public int opApplyImpl(O)(O operation)
    {
        int result;

        foreach (ref v; this.m_array[0..this.m_length])
        {
            result = operation(v);

            if (result)
            {
                break;
            }
        }

        return result;
    }

    public int opApplyIndexImpl(O)(O operation) const
    {
        int result;

        foreach (i, ref v; this.m_array[0..this.m_length])
        {
            result = operation(i, v);

            if (result)
            {
                break;
            }
        }

        return result;
    }

    public int opApplyImpl(O)(O operation) const
    {
        int result;

        foreach (ref v; this.m_array[0..this.m_length])
        {
            result = operation(v);

            if (result)
            {
                break;
            }
        }

        return result;
    }

    @nogc
    @property
    {
        public T[] data()
        {
            return this.m_array;
        }

        public size_t length()
        {
            return this.m_length;
        }

        public void length(in size_t value)
        in (value <= capacity)
        {
            this.m_length = value;
        }
        
        public size_t capacity()
        {
            return this.m_capacity;
        }

        public auto ref T front()
        {
            return this.m_array[0];
        }

        public auto ref T back()
        {
            return this.m_array[this.m_length - 1];
        }

        public bool empty()
        {
            return this.m_length == 0;
        }
    }
}
