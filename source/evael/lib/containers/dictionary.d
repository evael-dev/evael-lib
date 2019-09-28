module evael.lib.containers.dictionary;

import std.experimental.allocator : makeArray, expandArray, shrinkArray;

import evael.lib.memory;

struct KeyValueNode(K, V) 
{
    public K key;
    public V value;

    private KeyValueNode* next;

    public this(K key, V value, KeyValueNode* next) 
    {
        this.key = key;
        this.value = value;
        this.next = next;
    }
}

struct Dictionary(K, V)
{
    alias Node = KeyValueNode!(K, V);

    private Node*[] m_buckets;

    private int m_size = 0;

    public this(in size_t capacity) 
    {
        this.m_buckets = new Node*[capacity];
    }

    public void insert(K key, V value) 
    {
        immutable bucketIndex = typeid(key).getHash(&key) % this.m_buckets.length;

        Node* node = this.m_buckets[bucketIndex];

        if (node is null) 
        {
            this.m_buckets[bucketIndex] = New!Node(key, value, null);
            this.m_size++;
        } 
        else 
        {
            // We search for the same key and replace his value
            while (node.next !is null) 
            {
                if (node.key == key)
                {
                    node.value = value;
                    return;
                }
                node = node.next;
            }
            
            if (node.key == key) 
            {
                node.value = value;
            } 
            else 
            {
                node.next = New!Node(key, value, null);
                this.m_size++;
            }
        }
    } 

    /**
     * Returns value of key.
     */
    public V get(K key, V notFoundValue) 
    {
        auto node = this.getNode(key);

        if (node !is null)
        {
            return node.value;
        }
        
        return notFoundValue;
    }

    public void remove(K key)
    {
        auto node = this.getNode(key);

        if (node !is null)
        {
            Delete(node.value);
        }
    }

    private Node* getNode(K key)
    {
        auto i = typeid(key).getHash(&key) % this.m_buckets.length;
        Node* node = this.m_buckets[i];

        while (node !is null) 
        {
            if (key == node.key) 
            {
                return node.value;
            }
            node = node.next;
        }

        return null;
    }
}