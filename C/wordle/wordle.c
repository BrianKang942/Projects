// Copyright 2022 Min Jae Kang

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    char compare[255];  // character array for blacklisted characters
    // character array for temporary storage for textfile
    char buffer[255];
    int flag = 0;
    // if there are more than 2 command line arguments, throws error
    if (argc != 3) {
        printf("wordle: invalid number of args\n");
        return 1;
}

    FILE* lookfile = fopen(argv[1], "r");  // opens the list of string
        if (lookfile == NULL) {
            printf("wordle: cannot open file\n");
            return 1;
}
    // reads blacklisted characters and puts it into char array
    snprintf(compare, sizeof(compare), "%s\n", argv[2]);
    int length = strlen(compare);  // how many blacklisted characters there are

    while (fgets(buffer, 255, lookfile) != NULL) {
        flag = 0;  // reset flag to 0
        if (strlen(buffer) == 6) {  // words are at 5 characters only
            for (int i = 0; i < 5; i++) {  // check each char is not blacklisted
                for (int j = 0; j < length; j++) {
                    if (buffer[i] == compare[j]) {
                    flag = 1;  // if blacklist char is detected, throws flag
}}}

    if (flag == 0) {  // the word does not contain blacklisted characters
        for (int i = 0; i < 6; i++) {
            printf("%c", buffer[i]);
}}}}

    fclose(lookfile);  // close file
    return 0;
}












