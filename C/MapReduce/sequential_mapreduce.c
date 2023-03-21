#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <pthread.h>
#include "mapreduce.h"
#include "hashmap.h"

struct node {
    char* key;
    char* value;
};
struct list_data {
    int num_elements;
    int size;
    struct node** list;
};
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t buf_full = PTHREAD_COND_INITIALIZER;
pthread_cond_t buf_empty = PTHREAD_COND_INITIALIZER;
Mapper map_func;
Partitioner parthe t_func;
void *create_thread(void *);
void *thread_driver(void *);
void fill_buf(int);
struct list_data** list_info;
char* consume_buf();
char** filenames;
char* buffer;
int num_files;
int num_partitions;
int full = 0;
int max = 1;
int run = 1;

int cmp(const void* a, const void* b) {
    char* str1 = (*(struct kv **)a)->key;
    char* str2 = (*(struct kv **)b)->key;
    return strcmp(str1, str2);
}

/*
 * This function takes key-value pairs from many different mappers
 * and stores them in an array of linked-lists available for
 * reducers to use them at a later time. 
*/
void MR_Emit(char *key, char *value) {
    // call partition function
    // add kv pair to list at indicated partition
    // may need locks around the partition function, but probably not
    unsigned long partition_num = (*part_func)(key, num_partitions);
    struct node* kv = (struct node*)malloc(sizeof(struct node));
    kv->key = strdup(key);
    kv->value = strdup(value);
    pthread_mutex_lock(&lock);
    if (list_info[partition_num]->size == list_info[partition_num]->num_elements) {
        list_info[partition_num]->size *= 2;
        list_info[partition_num]->list = realloc(list_info[partition_num]->list, list_info[partition_num]->size * sizeof(struct node*));
    }
    list_info[partition_num]->list[list_info[partition_num]->num_elements++] = kv;
    pthread_mutex_unlock(&lock);
}

/*
 * This function decides which partition should get a particular
 * key/list of values to process.
*/
unsigned long MR_DefaultHashPartition(char *key, int num_partitions) {
    unsigned long hash = 5381;
    int c;
    while ((c = *key++) != '\0')
        hash = hash * 33 + c;
    return hash % num_partitions;
}

/*
 * This function helps with running the MapReduce infrastructure
 * by calling the functions passed to it by the user
*/
void MR_Run(int argc, char *argv[], 
	    Mapper map, int num_mappers, 
	    Reducer reduce, int num_reducers, 
	    Partitioner partition) {
    pthread_t threads[num_mappers];
    list_info = (struct list_data**)malloc(num_reducers * sizeof(struct list_data*));
    for (int i = 0; i < num_reducers; i++) {
        list_info[i] = (struct list_data*)malloc(sizeof(struct list_data));
        list_info[i]->list = (struct node**)malloc(10 * sizeof(struct node*));
        list_info[i]->num_elements = 0;
        list_info[i]->size = 10;
    }
    num_partitions = num_reducers;
    num_files = argc;
    filenames = argv;
    pthread_t driver;
    map_func = map;
    part_func = partition;
    // create threads
    pthread_create(&driver, NULL, thread_driver, NULL);
    for (int i = 0; i < num_mappers; i++)
        pthread_create(&threads[i], NULL, create_thread, NULL);

    // wait for each thread to finish
    pthread_join(driver, NULL);
    for (int j = 0; j < num_mappers; j++)
        pthread_join(threads[j], NULL);
}

/*
 * This wrapper function helps threads created in MR_Run call 
 * the user defined Map() function
*/
void *create_thread(void* pointer) {
    while (run) {
        pthread_mutex_lock(&lock);
        while (full != max) 
            pthread_cond_wait(&buf_full, &lock);
        char* file = consume_buf();
        pthread_cond_signal(&buf_empty);
        pthread_mutex_unlock(&lock);
        (*map_func)(file);
    }
    return (void*)pointer;
}

/*
 * This function feeds mapper threads file names
 * to perform the user defined map function on
*/
void *thread_driver(void* pointer) {
    for (int i = 1; i < num_files; i++) {
        pthread_mutex_lock(&lock);
        while (full == max)
            pthread_cond_wait(&buf_empty, &lock);
        fill_buf(i);
        pthread_cond_signal(&buf_full);
        pthread_mutex_unlock(&lock);
    }
    run = 0;
    return (void*)pointer;
}

/*
 * This function fills the buffer consumed by
 * create_thread and thread_driver
 */
void fill_buf(int index) {
    buffer = (char*)realloc(buffer ,sizeof(char) * strlen(filenames[index]));
    buffer = filenames[index];
    full = 1;
}

/*
 * This function consumes the buffer filled
 * by create_thread and thread_driver
*/
char* consume_buf() {
    full = 0;
    return strdup(buffer);
}
