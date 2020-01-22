module evael.lib.memory.no_gc_exception;

import evael.lib.memory : MemoryHelper;

class NoGCException : Throwable
{
    public bool instantiatedWithGC = true;

    /*
     * From object.d
     */
    @nogc @safe pure nothrow this(string msg, Throwable nextInChain = null)
    {
        super(msg, nextInChain);
    }

    /*
     * From object.d
     */
    @nogc @safe pure nothrow this(string msg, string file, size_t line, Throwable nextInChain = null)
    {
        super(msg, file, line, nextInChain);
    }
}

@nogc
void enforce(in bool condition, in string message, in string file = __FILE__, in size_t line = __LINE__)
{
    if (!condition)
    {
        throw MemoryHelper.create!NoGCException(message, file, line);
    }
}