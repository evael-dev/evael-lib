import std.stdio;

//import tanya.memory;

import evael.memory;
import evael.containers.Array;

@nogc
void main()
{
	class OhGod
	{
		int b;
		@nogc
		public this(int b)
		{
			this.b = b;
		}

				@nogc
		public ~this()
		{
		}
	}

	class Test : OhGod
	{
		int a;

		OhGod secondOne;
		@nogc
		public this(int a)
		{
			super(1336);
			secondOne = New!OhGod(5666);
			this.a = a;
		}

		@nogc
		public ~this()
		{
			//debug writeln("dtor");
			Delete!OhGod(secondOne);
		}
	}

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

	auto a = New!Toto(444);
	Delete!Toto(a);
	debug writeln(a is null);


	auto tests = Array!Test(500000);


	foreach(i; 0..500000)
	{
		tests[i] = New!Test(4444);
	}

	debug readln();

		foreach(i; 0..500000)
	{
		Delete(tests[i]);
	}

	debug readln();



	debug readln();

//debug defaultAllocator.reportStatistics(stdout);
debug defaultAllocator.reportPerCallStatistics(stdout);

}