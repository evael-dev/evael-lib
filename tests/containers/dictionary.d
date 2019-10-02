module tests.containers.dictionary;

import unit_threaded;
import evael.lib.containers.dictionary;

@Name("Dictionary inserts value with [] operator")
unittest
{
    auto dict = Dictionary!(int, int)(32);
    dict[1] = 1337;

    dict.get(1).shouldEqual(1337);
}

@Name("Dictionary overwrites existing value")
unittest
{
    auto dict = Dictionary!(int, int)(32);

    dict[1] = 1337;
    dict.get(1).shouldEqual(1337);

    dict[1] = 7331;
    dict.get(1).shouldEqual(7331);
}

@Name("Dictionary inserts value")
unittest
{
    auto dict = Dictionary!(int, int)(32);
    dict.insert(1, 1337);

    dict.get(1).shouldEqual(1337);
}

@Name("Dictionary returns default value when not found")
unittest
{
    auto dict = Dictionary!(int, int)(32);
    
    dict.get(1, -1).shouldEqual(-1);
}