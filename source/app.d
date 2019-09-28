import std.stdio;

//import tanya.memory;

import evael.lib.memory;
import evael.lib.containers.array;
import evael.lib.containers.dictionary;

interface I
{
    @nogc
    public void test();
}

class Oi : I
{
    string name;
    int b;

    @nogc
    public this(string name)
    {
        this.name = name;
    }

    @nogc
    public ~this()
    {
        debug writeln("destroy ", name);
    }

    @nogc
    public void test()
    {
        debug writeln("hi ", name);
    }
}
@nogc
void main()
{
    /*alias BoolArray = Array!bool;

    Array!BoolArray test;
    
    BoolArray first;
    first.insert(false);
    first.insert(true);
    
    test.insert(first);
    debug writeln(test);*/

    /*Array!I test;

    test.insert(New!Oi("rob"));
    test.insert(New!Oi("tom"));
    test[0].test();
    test[1].test();*/

    I a = New!Oi("roaaaaaaaaaaaaab");
    auto b = New!Oi("tom");

a.test();

    Delete(a);
    Delete(b);

 /*   auto a = Array!Oi();
    a.insert(New!Oi("rob"));

    debug writeln(a.length);
    foreach(i, obj; a)
    {
        debug writeln("Looping ", i, " " , obj);
    }*/

    /*class Toto
    {
        int a;
        @nogc
        public this(int a )
        {	
            this.a = a;
        }

        @nogc
        public ~this()
        {
            debug writeln("dtor");
        }
    }

    auto toto = New!Toto(5);
    debug writeln(toto.a);
    debug writeln(defaultAllocator.numAllocate);
    
    auto arr = Array!int(50, 1337);*/

    /*foreach(i, v; arr)
    {
        debug writeln(v);
    }*/


      /*  auto dict = Dictionary!(int, int)(32);
        dict.insert(5, 1);
        writeln(dict.get(5));*/

        /*arr.dispose();
        debug defaultAllocator.reportStatistics(stdout);*/
        struct Ha
        {
            int a;
            @nogc
            public this(int a)
            {
                this.a = a;
            }

            @nogc
            public ~this()
            {
                debug writeln("deleting");
            }
        }

        Ha* h = New!Ha(5);
        debug writeln(h.a);
        Delete(h);
    debug defaultAllocator.reportStatistics(stdout);

}