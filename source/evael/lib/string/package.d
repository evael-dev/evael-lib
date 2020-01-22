module evael.lib.string;

import evael.lib.containers.array;

struct Cstring
{
    private Array!char m_bytes;
    public const(char*) ptr;

    alias ptr this;

    @nogc
    public this(in string value)
    {
        this.m_bytes = Array!char(value.length + 1);
        this.m_bytes.length = value.length + 1;
        this.m_bytes[0..value.length] = cast(char[]) value[];
        this.m_bytes[value.length] = 0;

        this.ptr = this.m_bytes.data.ptr;
    }

    @nogc
    public ~this()
    {
        this.m_bytes.dispose();
    }
}