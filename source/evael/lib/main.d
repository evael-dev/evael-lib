import evael.lib.containers;

import std.stdio;
    import evael.lib.string;

class Test
{

    public Array!int ints;

    @nogc
    public void apply() const
    {
        foreach(i; ints)
        {
            import std.stdio;
            debug writeln(i);
        }
    }
}


@nogc
void cfunc(const(char*) str)
{
    debug writeln(str[0..5]);
}

@nogc
void dfunc(in string str)
{
    debug writeln(Cstring(str)[0..5]);
}


@nogc
void main()
{

    string hello = "hello";

    debug cfunc(Cstring(hello));
    debug dfunc(hello);

    //debug .dispose();

}