
//
// Title:           P3b Hash Table Implementation
// Files:           HashTable.java, HashTableTest.java, HashTableADT.java, 
//				    DataStructureADT.java, DuplicateKeyException.java
//					IllegalNullKeyException.java, KeyNotFoundException.java
				



import java.util.ArrayList; // import for ArrayList

// The collision resolution scheme I decided to use was bucket - array of linked nodes
// Furthermore, to resolve the collision, I used the technique called seperate chaining
//
// For my hashing algorithm, since it is a hash array using linked hashnodes, im using 
// the hashCode of the key % the initial capacity
// ig: Math.abs(codeHash) % initialCapacity - absolute in case of negative values

public class HashTable<K extends Comparable<K>, V> implements HashTableADT<K, V> {
	/*
	 * Private class of nodes to create the array of linked nodes
	 */
	private class HashNode {
		K key;
		V value;
		HashNode next;

		private HashNode(K key, V value) { // initializes the nodes
			this.key = key;
			this.value = value;
			this.next = null;
		}
	}

	private int initialCapacity; // How much space in array in total
	private double loadFactorThreshold; // the limit of how "full" the array can be
	private int size; // number of keys/value in array
	private ArrayList<HashNode> hasharray = new ArrayList<>(); // Initializes the hashtable array

	public HashTable() { // no-arg constructor
		this.initialCapacity = 14; // initialize capacity with typical amount
		this.loadFactorThreshold = 0.75; // initialize threshold with typical amount
		this.size = 0; // 0 inserts at the moment
		for (int i = 0; i < initialCapacity; i++) { // initialize the hasharray
			hasharray.add(null);
		}
	}

	public HashTable(int initialCapacity, double loadFactorThreshold) { // constructor with arg

		this.initialCapacity = initialCapacity; // initialize capacity with user info
		this.loadFactorThreshold = loadFactorThreshold; // initialize threshold with user info
		this.size = 0; // 0 inserts at the moment

		for (int i = 0; i < initialCapacity; i++) { // initialize the hasharray
			hasharray.add(null);
		}
	}

	/*
	 * This method generates the hashCode for the keys
	 */
	private int bucketIndex(K key) {
		int codeHash = key.hashCode();
		return Math.abs(codeHash) % initialCapacity; // Absolute value since hashCode is negative sometimes
	}

	/*
	 * Add the key,value pair to the data structure and increase the number of keys.
	 * If key is null, throw IllegalNullKeyException; If key is already in data
	 * structure, throw DuplicateKeyException();
	 */
	@Override
	public void insert(K key, V value) throws IllegalNullKeyException, DuplicateKeyException {
		if (key == null) { // user inputs null key; invalid input
			throw new IllegalNullKeyException();
		}

		int bucketIndexKey = bucketIndex(key); // Gets hashCode for key
		HashNode head = hasharray.get(bucketIndexKey);
		HashNode newNode = new HashNode(key, value); // creates Node for key/value
		newNode.key = key; //the new Node to be inserted key
		newNode.value = value; // the new Node to be inserted value

		if (head == null) { // empty array
			hasharray.set(bucketIndexKey, newNode);
			size++;
		} else {
			while (head != null) { // checks if there is a duplicate key
				if (head.key.equals(key)) {
					throw new DuplicateKeyException();
				}
				head = head.next;
			}
			if (head == null) { // if no duplicate key
				head = hasharray.get(bucketIndexKey);
				newNode.next = head;
				hasharray.set(bucketIndexKey, newNode);
				size++;
			}
		}
		getCapacity();  // calls getCapacity if after insert, to check if the loadFactor surpasses
						// the threshold
	}

	/*
	 * If key is found, remove the key,value pair from the data structure decrease
	 * number of keys. return true If key is null, throw IllegalNullKeyException If
	 * key is not found, return false
	 */
	@Override
	public boolean remove(K key) throws IllegalNullKeyException {
		if (key == null) { // user input key cannot be null
			throw new IllegalNullKeyException();
		}
		int bucketIndexKey = bucketIndex(key); // get the hashCode for key
		HashNode head = hasharray.get(bucketIndexKey);
		if (head == null) { // nothing there to remove
			return false;
		}
		if (head.key.equals(key)) { // found the key to remove
			head = head.next;
			hasharray.set(bucketIndexKey, head); // replace that key with the next one
			size--;
			return true;

		} else { // if the head key was not the key to remove, continue to iterate
			HashNode prev = null;
			while (head != null) {
				if (head.key.equals(key)) {
					prev.next = head.next;
					size--;
					return true;
				}
				prev = head;
				head = head.next;
			}
			size--;
			return true;
		}

	}

	/*
	 * Returns the value associated with the specified key Does not remove key or
	 * decrease number of keys
	 *
	 * If key is null, throw IllegalNullKeyException If key is not found, throw
	 * KeyNotFoundException().
	 */
	@Override
	public V get(K key) throws IllegalNullKeyException, KeyNotFoundException {
		if (key == null) { // user inputted key cannot be null
			throw new IllegalNullKeyException();
		}

		int bucketIndexKey = bucketIndex(key);
		HashNode head = hasharray.get(bucketIndexKey); // with index, iterate until found key

		while (head != null) {
			if (head.key.equals(key)) {
				return head.value; // returns the value of key

			}
			head = head.next; // if head was not wanted key, go next of head and repeat
		}

		throw new KeyNotFoundException(); // if key cannot be found
	}

	// Returns the number of key,value pairs in the data structure
	@Override
	public int numKeys() {

		return size;
	}

	/*
	 * Returns the load factor threshold that was passed into the constructor when
	 * creating the instance of the HashTable. When the current load factor is
	 * greater than or equal to the specified load factor threshold, the table is
	 * resized and elements are rehashed.
	 */
	@Override
	public double getLoadFactorThreshold() {
		if (getLoadFactor() <= loadFactorThreshold) { // calls getLoadFactor to check size/initialCapacity
			getCapacity(); // called if current load factor is greater or equal to threshold
			return loadFactorThreshold;
		}
		return loadFactorThreshold;
	}

	/*
	 * Returns the current load factor for this hash table load factor = number of
	 * items / current table size
	 */
	@Override
	public double getLoadFactor() {
		double currentLoadFactor;
		currentLoadFactor = ((double) size) / initialCapacity; // cast size to double since loadfactor is double
		return currentLoadFactor;
	}

	/*
	 * Return the current Capacity (table size) of the hash table array. The initial
	 * capacity must be a positive integer, 1 or greater and is specified in the
	 * constructor. When the load factor threshold is reached, the capacity must
	 * increase to: 2 * capacity + 1 Once increased, the capacity never decreases
	 */
	@Override
	public int getCapacity() { // size and initialCapacity cast into "double"
		if (((double) size) / ((double) initialCapacity) >= loadFactorThreshold) {

			ArrayList<HashNode> temp = hasharray; // create temp array of linked nodes with hasharray
			hasharray = new ArrayList<>(); // new arrayList
			initialCapacity = (2 * initialCapacity) + 1; // increase the initial capacity
			size = 0; // size back to 0

			for (int i = 0; i < initialCapacity; i++) { // initializing the new hasharray
				hasharray.add(null);
			}

			for (HashNode headNode : temp) {
				while (headNode != null) { // adding in the key/value into the hasharray
											// will be rehashed
					try { // try catch in case of illegal null or duplicates

						insert(headNode.key, headNode.value);
					} catch (IllegalNullKeyException | DuplicateKeyException e) {

						e.printStackTrace();
					}

					headNode = headNode.next;

				}
			}
		}

		return initialCapacity;
	}

	/*
	 * Returns the collision resolution scheme used for this hash table. Implement
	 * with one of the following collision resolution strategies. Define this method
	 * to return an integer to indicate which strategy.
	 */
	@Override
	public int getCollisionResolution() {

		return 5; // 5 CHAINED BUCKET: array of linked nodes
	}

}
