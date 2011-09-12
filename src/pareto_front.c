/* 
   Copyright (c) 2009, Yi Cao
   All rights reserved.

   Redistribution and use in source and binary forms, with or without 
   modification, are permitted provided that the following conditions are 
   met:

   * Redistributions of source code must retain the above copyright 
   notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright 
   notice, this list of conditions and the following disclaimer in 
   the documentation and/or other materials provided with the distribution
      
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
   POSSIBILITY OF SUCH DAMAGE.
*/


#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
/*
  The pareto_front returns the logical Pareto membership of a set of
  points by minimising.


  Created by Yi Cao (y.cao@cranfield.ac.uk).
  Modified by Shane Celis to work on unix and with row major matrices.

*/

#define true  1
#define false 0

void pareto_front_colmajor(int * front, double * M, unsigned int row, unsigned int col)
{
  unsigned int t,s,i,j,j1,j2;
  int *checklist, coldominatedflag;
    
  checklist = (int *)malloc(row*sizeof(int));
  for(t = 0; t<row; t++) { checklist[t] = true; front[t] = false; }
  for(s = 0; s<row; s++) {
    t=s;
    if (!checklist[t]) continue;
    checklist[t]=false;
    coldominatedflag=true;
    for(i=t+1;i<row;i++) {
      if (!checklist[i]) continue;
      checklist[i]=false;
      for (j=0,j1=i,j2=t;j<col;j++,j1+=row,j2+=row) {
        //printf("(%d,%d) -> %d, (%d,%d) -> %d\n", i,j, j1, t, j, j2);
        if (M[j1] < M[j2]) {
          checklist[i]=true;
          break;
        }
      }
      if (!checklist[i]) continue;
      coldominatedflag=false;
      for (j=0,j1=i,j2=t;j<col;j++,j1+=row,j2+=row) {
        if (M[j1] > M[j2]) {
          coldominatedflag=true;
          break;
        }
      }
      if (!coldominatedflag) {     //swap active index continue checking
        front[t]=false;
        checklist[i]=false;
        coldominatedflag=true;
        t=i;
      }
    }
    front[t]=coldominatedflag;
    if (t>s) {
      for (i=s+1; i<t; i++) {
        if (!checklist[i]) continue;
        checklist[i]=false;
        for (j=0,j1=i,j2=t;j<col;j++,j1+=row,j2+=row) {
          if (M[j1] < M[j2]) {
            checklist[i]=true;
            break;
          }
        }
      }
    }
  }
  free(checklist); 
}

void pareto_front_rowmajor(int * front, double * M, unsigned int row, unsigned int col)
{
  unsigned int t,s,i,j,j1,j2;
  int *checklist, coldominatedflag;
    
  checklist = (int *)malloc(row*sizeof(int));
  for(s = 0; s<row; s++) { checklist[s] = true; front[s] = false; }
  for(t = 0; t<row; t++) {
    if (!checklist[t]) continue;
    checklist[t]=false;
    coldominatedflag=true;
    for(i=t+1;i<row;i++) {
      if (!checklist[i]) continue;
      checklist[i]=false;
      for (j=0;j<col;j++) {
        j1=i*col + j;
        j2=t*col + j;
        // go through columns 
        //printf("(%d,%d) -> %d, (%d,%d) -> %d\n", i,j, j1, t, j, j2);
        if (M[j1] < M[j2]) {
          checklist[i]=true;
          break;
        }
      }
      if (!checklist[i]) continue;
      coldominatedflag=false;
      for (j=0;j<col;j++) {
        j1=i*col + j;
        j2=t*col + j;
        if (M[j1] > M[j2]) {
          coldominatedflag=true;
          break;
        }
      }
      if (!coldominatedflag) {     //swap active index continue checking
        front[t]=false;
        checklist[i]=false;
        coldominatedflag=true;
        t=i;
      }
    }
    front[t]=coldominatedflag;
    if (t>s) {
      for (i=s+1; i<t; i++) {
        if (!checklist[i]) continue;
        checklist[i]=false;
        for (j=0,j1=i,j2=t;j<col;j++) {
          j1=i*col + j;
          j2=t*col + j;
          if (M[j1] < M[j2]) {
            checklist[i]=true;
            break;
          }
        }
      }
    }
  }
  free(checklist); 
}

#ifdef MAIN
#include <math.h>

#define rand drand48
int main(int argc, char **argv) {
  
  double a,b,c,d,e,f;
  a = rand() * 200;
  b = rand() * 200;
  c = rand() * 200;
  d = rand() * 200;
  e = rand() * 200;
  f = rand() * 200;
  
  // Matrix is in column-major order
  // So treat each column as though that's a point in objective space.
  double M[] = {a, c, e,
                b, d, f,
  };

  double Mrow[] = {a,b,
                   c,d,
                   e,f
  };


  // Finds the minimum pareto front.
  unsigned int row = 3;
  unsigned int col = 2;
  int i, front[row], front2[row];
  pareto_front(front, M, row, col);
  for (i = 0; i < row; i++) 
    printf("%d ", front[i]);
  printf("\n");
  printf("ROWMAJOR\n");
  pareto_front_rowmajor(front2, Mrow, row, col);
  for (i = 0; i < row; i++) 
    printf("%d ", front2[i]);
  printf("\n");
  for (i = 0; i < row; i++)
    if (front[i] != front2[i]) {
      fprintf(stderr, "ACK! (a,b,c,d,e,f) = (%f,%f,%f,%f,%f,%f)\n", a,b,c,d,e,f);
      return 1;
    }
      
  return 0;
}
#endif //MAIN
