import evael.lib.containers;

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



void main()
{

    Test test = new Test();
    test.apply();
}