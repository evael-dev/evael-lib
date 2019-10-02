module evael.lib.containers.dictionary;

import evael.lib.memory;
import evael.lib.containers.array;

struct KeyValueNode(K, V) 
{
    public K key;
    public V value;

    private KeyValueNode* next;

    @nogc
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

    private Array!(Node*) m_buckets;

	/**
	 * Dictionary constructor.
	 * Params:
	 *		capacity : bucket capacity
	 */
    @nogc
    public this(in size_t capacity) 
    {
        this.m_buckets = Array!(Node*)(capacity, null);
    }

	/**
	 * Dictionary destructor.
	 */
	@nogc
	public void dispose()
	{
        foreach (Node* node; this.m_buckets)
		{
			Node* currentNode = node;
            while (currentNode !is null)
			{
                Node* prevNode = currentNode;
                currentNode = currentNode.next;
                Delete(prevNode);
            }
        }

		this.m_buckets.dispose();
	}

	/**
	 * Inserts a key and his value.
	 * Params:
	 *		key : key
	 *		value : value
	 */
    @nogc
    public void insert(K key, V value) 
    {
        immutable hash = this.getHash(key);

        Node* node = this.m_buckets[hash];

        if (node is null) 
        {
            this.m_buckets[hash] = New!Node(key, value, null);
        } 
        else 
        {
            // We search for the same key and replace his value
            while (node !is null)
            {
                if (node.key == key)
                {
                    node.value = value;
                    return;
                }
                node = node.next;
            }
            
			node.next = New!Node(key, value, null);
        }
    } 

    /**
     * Returns value of key.
	 * Params:
	 *		key : key
	 *		notFoundValue : value to return if key has not been found
     */
    @nogc
    public V get(K key, V notFoundValue = V.init) 
    {
        immutable hash = this.getHash(key);

        Node* currentNode = this.m_buckets[hash];

        while (currentNode !is null) 
        {
            if (currentNode.key == key)
            {
                return currentNode.value;
            }
            currentNode = currentNode.next;
        }
        
        return notFoundValue;
    }

	/**
	 * Removes a key and his value from the dictionary.
	 * Params:
	 *		key : key
	 */
    @nogc
    public bool remove(K key)
    {
        immutable hash = this.getHash(key);

		Node* prevNode = null;
        Node* currentNode = this.m_buckets[hash];

        while (currentNode !is null && currentNode.key != key) 
		{
            prevNode = currentNode;
            currentNode = currentNode.next;
        }

        if (currentNode is null)
		{
            return false;
        }

		if (prevNode is null) 
		{
			this.m_buckets[hash] = currentNode.next;
		} 
		else 
		{
			prevNode.next = currentNode.next;
		}

		Delete(currentNode);

        return true;
    }

    /**
     * Index assignment support.
     */
    pragma(inline, true)
    @nogc
    public void opIndexAssign(V value, K key)
    {
        this.insert(key, value);
    }

    @nogc
    private size_t getHash(K)(K key) if(is(K == int))
    {
        return key % this.m_buckets.length;
    }

    @nogc
    private size_t getHash(K)(K key) if(is(K == string))
    {
        int hash = 7;
        foreach (c; key)
        {
            hash = hash * 31 + c;
        }

        return hash % this.m_buckets.length;
    }
}