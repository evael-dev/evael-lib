import std.stdio;

//import tanya.memory;

import evael.memory;
import evael.containers.array;
import evael.containers.dictionary;

@nogc
void main()
{
	class Toto
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
	
	auto arr = Array!int(50, 1337);

	/*foreach(i, v; arr)
	{
		debug writeln(v);
	}*/

	debug
	{	
		/*auto dict = Dictionary!(int, int)(32);
		dict.insert(5, 1);
		writeln(dict.get(5));*/
		struct Ha
		{
			int a;
			public this(int a)
			{
				this.a = a;
			}
		}

		auto h = New!Ha(5);

		Delete(h);
		assert(h is null);
	}
}