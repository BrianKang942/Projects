#include "user.h"
#include "types.h"
#include "stat.h"
#include "pstat.h"

int main(void) {
    struct pstat *stat = (struct pstat*)malloc(sizeof(struct pstat));
    getpinfo(stat);
    exit();
}
