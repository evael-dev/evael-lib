import unit_threaded;

int main(string[] args)
{
    return args.runTests!(
                          "tests.containers.array",
                          "tests.containers.dictionary",
                          "tests.memory",
                          "tests.memory.no_gc_class"
                          );
}
