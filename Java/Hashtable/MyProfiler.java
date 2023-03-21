
// Used as the data structure to test our hash table against
import java.util.*;

public class MyProfiler<K extends Comparable<K>, V> {

	HashTableADT<K, V> hashtable;
	TreeMap<K, V> treemap;

	@SuppressWarnings({ "unchecked", "rawtypes" })
	public MyProfiler() {

		treemap = new TreeMap(); // initializes the TreeMap
		hashtable = new HashTable(14, 0.75); // initializes the HashTable with 14 space, with loadfactor 0.75
	}

	public void insert(K key, V value) throws IllegalNullKeyException {

		if (key == null) { // user inputs null key; invalid input
			throw new IllegalNullKeyException();
		}

		treemap.put(key, value); // add in key/value for treemap

		try { // in case of duplicate keys
			hashtable.insert(key, value); // adds in key/value for hashtable
		} catch (DuplicateKeyException e) {

			e.printStackTrace();
		}
	}

	public void retrieve(K key) throws IllegalNullKeyException {

		if (key == null) { // user inputs null key; invalid input
			throw new IllegalNullKeyException();
		}
		treemap.get(key); // gets value of key in treemap

		try { // in case key is not found
			hashtable.get(key); // gets value of key in hashtable
		} catch (KeyNotFoundException e) {

			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		try { // my profiler implementation
			int numElements = Integer.parseInt(args[0]);
			MyProfiler<Integer, Integer> profile = new MyProfiler<Integer, Integer>();
			for (Integer i = 0; i < numElements; i++) {
				profile.insert(i, i); // inserts as much as numElements
			}

			for (Integer p = 0; p < numElements; p++) {
				profile.retrieve(p); // should retrieve or get all values
			}

			String msg = String.format("Inserted and retreived %d (key,value) pairs", numElements);
			System.out.println(msg);
		} catch (Exception e) {
			System.out.println("Usage: java MyProfiler <number_of_elements>");
			System.exit(1);
		}
	}

}
