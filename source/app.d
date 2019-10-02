import std.stdio;

//import tanya.memory;

import evael.lib.memory;

import evael.lib.containers.array;
import evael.lib.containers.dictionary;

interface I : NoGCInterface
{
    @nogc
    public void test();
}

class Oi : NoGCClass, I
{
    int[5000] itaketoomuchmemory;
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
/*
    I a = New!Oi("roaaaaaaaaaaaaab");
    auto b = New!Oi("tom");

a.test();

    Delete(a);
    Delete(b);*/

import std.traits;

    debug 
    {
       /* Array!I iis;
        iis.insert(New!Oi("lol"));
        iis.insert(new Oi("aaaa"));

        iis.dispose();*/
     /*   I a = New!Oi("aaa");
        NoGCClass c = cast (NoGCClass) a;
        writeln(c.instantiatedWithGC);
        Delete(a);
      //  assert(a is null);
        readln();*/

        class Test : NoGCClass
        {
            public double[3000] floats = 1337;
            public int x;

            @nogc
            public this(int x)
            {
                this.x = x;
            }
            @nogc
            public ~this()
            {
                debug writeln("disposing...");
            }
        } 
        import core.memory;
    

        //Test t = Array!Test(5);
        Test test = new Test(1337);
        Test b = test;
        readln();

        destroy(test);
        GC.collect();
        
        writeln(b.x);
        destroy(b);
        GC.collect();

        readln();

    }
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


       /* debug auto dict = Dictionary!(int, int)();
        debug dict.insert(5, 1);
        debug writeln(dict.get(5));
        debug writeln(dict.get(999, -1));
        debug dict.remove(5);
        debug writeln(dict.get(5, -1));


        debug auto dicta = Dictionary!(string, string)(32);
        debug dicta.insert("5", "loioooooooooooooool");
        debug dicta["6"] = "aaaaaaaaaaaaaaaaaaa";

        debug writeln(dicta.get("5"));
        debug writeln(dicta.get("6"));
        debug dicta.remove("5");
        debug writeln(dicta.get("5", "empty"));
        debug writeln(dicta.get("6", "empty"));*/
        debug
        {
           /* int*[] ints = new int*[2];
            ints[0] = new int(6);
            ints[1] = new int(7);
            writeln(*ints[0]);

            int* test = ints[0];
            test = new int(999);
            writeln(*ints[0]);*/
        }

      /*  struct Lol
        {
            int[5000000] x;
        }

        auto lol = New!Lol();
        debug writeln(lol);
        debug readln();
        Delete(lol);
        debug writeln(lol);
        debug readln();
*/
        debug
        {
          /*  import std.experimental.allocator;
            Lol* p = theAllocator.make!Lol(42);
writeln(p);
// Destroy and deallocate it
theAllocator.dispose(p);
writeln(p);*/
        }
        /*arr.dispose();
        debug defaultAllocator.reportStatistics(stdout);*/
       /* struct Ha
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
    debug defaultAllocator.reportStatistics(stdout);*/
/*debug   
{
    auto bo = Array!bool(3, false);
    auto bt = Array!bool(3, false);

    auto br = Array!bool(3, false);

    br.data[] = bo.data[] & bt.data[];
    writeln(br);
}*/
}