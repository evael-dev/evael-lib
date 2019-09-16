module evael.containers.array;

import std.experimental.allocator : makeArray, expandArray, shrinkArray;

public import evael.memory;

struct Array(T)
{
    private T[] m_array;

    private size_t m_capacity;
    private size_t m_length;

    /**
     * Creates an default-initialized array.
     * Params:
     * 		capacity : capacity of the arrray
     */
    @nogc
    public this(in size_t capacity)
    {
        this.m_array = defaultAllocator.makeArray!T(capacity);
        this.m_capacity = capacity;
    }

    /**
     * Creates an initialized array.
     * Params:
     * 		capacity : capacity of the array
     *		defaultValue : default value
     */
    public this(in size_t capacity, T defaultValue)
    {
        this.m_array = cast(T[]) defaultAllocator.allocate(T.sizeof * capacity);
        this.m_array[] = defaultValue;
        this.m_capacity = capacity;
        this.m_length = capacity;
    }		

    @nogc
    public ~this()
    {
        this.dispose();
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
            this.m_array = defaultAllocator.makeArray!T(32);
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
     *		i : indexs
     */
    @nogc
    public void removeAt(in size_t i)
    in (i < this.m_length)
    {
        static if (is(T == class) || is(T == interface))
        {
            Delete(this.m_array[i]);
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
    public void opSliceAssign(T value, size_t i, size_t j)
    {
        this.m_array[i .. j] = value;
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
     * @nogc foreach support.
     */
    @nogc
    public int opApply(scope int delegate(size_t i, ref T) @nogc operation)
    {
        return opApplyImpl(operation);
    }

    /**
     * foreach support.
     */
    public int opApply(scope int delegate(size_t i, ref T) operation)
    {
        return opApplyImpl(operation);
    }

    public int opApplyImpl(O)(O operation)
    {
        int result;

        foreach (i, ref v; this.m_array)
        {
            result = operation(i, v);

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
        public T* data()
        {
            return this.m_array.ptr;
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
