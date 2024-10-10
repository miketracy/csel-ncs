#include <stdio.h>
#include <unistd.h>

int main () {
  int me = getuid();
  int akshual = geteuid();
  printf("You are UID %d\n", me);
  printf("Running as UID %d\n", akshual);
}
