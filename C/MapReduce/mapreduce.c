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
    pthread_mutex_t part_lock;
    int part_counter;
};
struct file_info {
    int num_files;
    int available;
    int done;
    char* curr_file;
    int count;
    char** filenames;
}info;
struct reduce_info {
    int part;
}reduce_inf;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t reduce_lock = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t buf_full = PTHREAD_COND_INITIALIZER;
pthread_cond_t buf_empty = PTHREAD_COND_INITIALIZER;
Mapper map_func;
Partitioner part_func;
Reducer reduce_func;
void *consumer(void *);
void *producer(void *);
void *reduce_all(void *);
int cmp(const void*, const void*);
char* get_func(char*, int);
void fill_buf(int);
char* consume_buf();
pthread_t driver;
struct list_data** list_info;
char** filenames;
char* buffer;
int num_files;
int num_partitions;
int full = 0;
int max = 1;
int run = 1;

/*
 * This function takes key-value pairs from many different mappers
 * and stores them in an array of linked-lists available for
 * reducers to use them at a later time. 
*/
void MR_Emit(char *key, char *value) {
    unsigned long partition_num = (*part_func)(key, num_partitions);
    struct node* kv = (struct node*)malloc(sizeof(struct node));
    kv->key = strdup(key);
    kv->value = strdup(value);
    pthread_mutex_lock(&list_info[partition_num]->part_lock);
    if (list_info[partition_num]->size == list_info[partition_num]->num_elements) {
        list_info[partition_num]->size *= 2;
        list_info[partition_num]->list = realloc(list_info[partition_num]->list, list_info[partition_num]->size * sizeof(struct node*));
    }
    list_info[partition_num]->list[list_info[partition_num]->num_elements++] = kv;
    pthread_mutex_unlock(&list_info[partition_num]->part_lock);
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
    pthread_t threads[num_mappers + 1];
    list_info = (struct list_data**)malloc(num_reducers * sizeof(struct list_data*));
    for (int i = 0; i < num_reducers; i++) {
        list_info[i] = (struct list_data*)malloc(sizeof(struct list_data));
        list_info[i]->list = (struct node**)malloc(100 * sizeof(struct node*));
        list_info[i]->num_elements = 0;
        list_info[i]->size = 100;
        list_info[i]->part_lock = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
        list_info[i]->part_counter = 0;
    }
    info.count = 1;
    info.available = 0;
    info.num_files = argc;
    info.done = 0;
    reduce_inf.part = 0;
    num_partitions = num_reducers;
    num_files = argc;
    filenames = argv;
    map_func = map;
    part_func = partition;
    reduce_func = reduce;
    // create threads
    for (int i = 0; i < num_mappers + 1; i++) {
        if (i == num_mappers) {
            pthread_create(&threads[i], NULL, producer, NULL);
            continue;
        }
        pthread_create(&threads[i], NULL, consumer, NULL);
    }

    // wait for each thread to finish
    for (int j = 0; j < num_mappers + 1; j++) {
        pthread_join(threads[j], NULL);
    }

    // sort partitions
    for (int i = 0; i < num_partitions; i++)
        qsort(list_info[i]->list, list_info[i]->num_elements, sizeof(struct node*), cmp);
    
    // reduce
    pthread_t reducer_threads[num_partitions];
    for (int i = 0; i < num_partitions; i++) {
        pthread_create(&reducer_threads[i], NULL, reduce_all, NULL);
    }
    for (int i = 0; i < num_partitions; i++)
        pthread_join(reducer_threads[i], NULL);
}

/*
 * This wrapper function helps threads created in MR_Run call 
 * the user defined Map() function
*/
void *consumer(void* pointer) {
    while (!(info.done)) {
        pthread_mutex_lock(&lock);
        while (!(info.available) && !(info.done)) 
            pthread_cond_wait(&buf_full, &lock);
        if (info.available) {
            (*map_func)(info.curr_file);
            info.available = 0;
            if (info.done) {
                pthread_mutex_unlock(&lock);
                pthread_exit(NULL);
            }
        }
        if (info.done) {
            pthread_mutex_unlock(&lock);
            pthread_exit(NULL);
        }
        pthread_cond_signal(&buf_empty);
        pthread_mutex_unlock(&lock);
    }
    pthread_exit(NULL);
}

/*
 * This function feeds mapper threads file names
 * to perform the user defined map function on
*/
void *producer(void* pointer) {
    int i = 1;
    while (i < num_files) {
        pthread_mutex_lock(&lock);
        while (info.available) {
            if (info.done) {
                 pthread_mutex_unlock(&lock);
                 pthread_exit(NULL);
            }
            pthread_cond_wait(&buf_empty, &lock);
        }
        info.curr_file = filenames[i++];
        info.available = 1;
        if (i == num_files)
            info.done = 1;
        pthread_cond_broadcast(&buf_full);
        pthread_mutex_unlock(&lock);
    }
    pthread_exit(NULL);
}

/*
 * This function calls reduce on each partition
*/
void *reduce_all(void* pointer) {
    pthread_mutex_lock(&reduce_lock);
    int part = reduce_inf.part++;
    pthread_mutex_unlock(&reduce_lock);
    while (list_info[part]->part_counter < list_info[part]->num_elements) {
        //printf("counter = %d\n", *part);
        (*reduce_func)((list_info[part]->list[list_info[part]->part_counter])->key, get_func, part);
    }
    pthread_exit(NULL);
}

/*
 * This function finds a matching key in a partition
 * and returns its value
*/
char* get_func(char* key, int partition_number) {
    // no need for locks as partition number is specified
    if (list_info[partition_number]->num_elements == list_info[partition_number]->part_counter)
        return NULL;
    struct node *kv = list_info[partition_number]->list[list_info[partition_number]->part_counter];
    if (!strcmp(kv->key, key)) {
        list_info[partition_number]->part_counter++;
        return kv->value;
    }
    return NULL;
}

/*
 * This function compares two keys for the use of qsort
*/
int cmp(const void* a, const void* b) {
    char* str1 = (*(struct node **)a)->key;
    char* str2 = (*(struct node **)b)->key;
    return strcmp(str1, str2);
}