import std.stdio;

//import tanya.memory;

import evael.memory;
import evael.containers.array;
import evael.containers.dictionary;

interface I
{
	@nogc
	public void test();
}

class Oi : I
{
	string name;

	@nogc
	public this(string name)
	{
		this.name = name;
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

	Array!I test;

	test.insert(New!Oi("rob"));
	test.insert(New!Oi("tom"));
	test[0].test();
	test[1].test();


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


		/*auto dict = Dictionary!(int, int)(32);
		dict.insert(5, 1);
		writeln(dict.get(5));*/

		/*arr.dispose();
		debug defaultAllocator.reportStatistics(stdout);
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
				debug writeln("god");
			}
		}

		auto h = Ha(5);
		debug writeln(h.a);*/
	
}