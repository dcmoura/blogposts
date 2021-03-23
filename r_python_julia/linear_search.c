// Copyright (c) 2021 Daniel C. Moura
// https://towardsdatascience.com/r-vs-python-vs-julia-90456a2bcbab
// linkedin.com/in/dmoura
// twitter.com/daniel_c_moura

// compiling this file:
// gcc linear_search.c -O3

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#define MAX_LINE_LEN 10
#define ARRAY_SIZE 1000000

// 0.26 seconds
int for_search(const int *vec, int size, int x) {
  for (int i=0;i<size;i++)
    if (vec[i] == x)
      return 1;
  return 0;
}

int main() {
  char *filename = "vec.txt";
  FILE *f;
  char line[MAX_LINE_LEN];
  int vec[ARRAY_SIZE];
  clock_t start, end;
  double elapsed_used;

  //simple file reading with predefined number of lines
  f = fopen(filename, "r");
  int i = 0;
  while (fgets(line, MAX_LINE_LEN, f) != NULL)
    vec[i++] = (int) strtoul(line, NULL, 0);
  fclose(f);
  printf("%d records\n", i);

  for (int r=0;r<3;r++) { // three runs        
    start = clock();

    int nmatches = 0;
    for (int i=1;i<=1000;i++)
      if (for_search(vec, ARRAY_SIZE, i))
        nmatches++;

    end = clock();
    elapsed_used = ((double)(end - start)) / CLOCKS_PER_SEC;

    printf("elapsed CPU time: %f seconds\n", elapsed_used);
    printf("\tmatches: %d\n", nmatches);
  }
  return 0;
}
