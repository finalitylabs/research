#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <stdbool.h>
#include "for.h"
#include "sha256.c"

#define __STDC_FORMAT_MACROS
#define LEN 1000
uint32_t in[LEN] = {0};
uint8_t out[512];

void read_ints (const char* file_name)
{
  FILE* file = fopen (file_name, "r");
  int i = 0;

  fscanf (file, "%d", &i);    
  while (!feof (file))
    {  
      printf ("%d ", i);
      fscanf (file, "%d", &i);      
    }
  fclose (file);        
}

uint32_t sha_to_int32(uint32_t _input, uint32_t nonce)
{
  SHA256_CTX h;
  BYTE buf[SHA256_BLOCK_SIZE];
  BYTE i[] = {"1"};
  WORD b[] = {_input};
  WORD c[] = {nonce};

  char str[64];
  sha256_init(&h);
  //sha256_update(&h, i, strlen(i));
  sha256_update(&h, b, sizeof(b[0]));
  sha256_update(&h, c, sizeof(c[0]));
  sha256_final(&h, buf);

  unsigned char * pin = buf;
  const char * hex = "0123456789ABCDEF";
  char * pout = str;
  for(; pin < buf+sizeof(buf); pout+=2, pin++){
    pout[0] = hex[(*pin>>4) & 0xF];
    pout[1] = hex[ *pin     & 0xF];
    //pout[2] = ':';
  }
  pout[-1] = 0;

  //printf("hash: %s\n", str);
  uint32_t myInt1 = (buf[0] << 24) + (buf[1] << 16) + (buf[2] << 8) + buf[3];
  //uint64_t myInt1 = (buf[0] << 56) + (buf[1] << 48) + (buf[2] << 40) + (buf[3] << 32) + (buf[4] << 24) + (buf[5] << 16) + (buf[6] << 8) + buf[7];
  //printf("number:%"PRIu64"\n", myInt1);
  return myInt1;
}

uint64_t modexp(uint64_t x, uint64_t y, uint64_t p) 
{ 
  uint64_t res = 1;      // Initialize result 
  x = x % p;  // Update x if it is more than or 
              // equal to p 
  while (y > 0) 
  { 
    // If y is odd, multiply x with result 
    if (y & 1) 
      res = (res*x) % p; 

    // y must be even now 
    y = y>>1; // y = y/2 
    x = (x*x) % p; 
  } 
  return res; 
} 

bool miillerTest(uint64_t d, uint64_t n) 
{ 
    // Pick a random number in [2..n-2] 
    // Corner cases make sure that n > 4 
    uint64_t a = 2 + rand() % (n - 4); 
  
    // Compute a^d % n 
    uint64_t x = modexp(a, d, n); 
  
    if (x == 1  || x == n-1) 
      return true; 
  
    // Keep squaring x while one of the following doesn't 
    // happen 
    // (i)   d does not reach n-1 
    // (ii)  (x^2) % n is not 1 
    // (iii) (x^2) % n is not n-1 
    while (d != n-1) 
    { 
      x = (x * x) % n; 
      d *= 2; 

      if (x == 1)      return false; 
      if (x == n-1)    return true; 
    } 
  
    // Return composite 
    return false; 
}

bool isPrime(uint64_t n, uint64_t k) 
{ 
    // Corner cases 
    if (n <= 1 || n == 4)  return false; 
    if (n <= 3) return true; 
  
    // Find r such that n = 2^d * r + 1 for some r >= 1 
    uint64_t d = n - 1; 
    while (d % 2 == 0) 
      d /= 2; 
  
    // Iterate given nber of 'k' times 
    for (uint64_t i = 0; i < k; i++) 
      if (!miillerTest(d, n)) 
        return false; 
  
    return true; 
} 

uint32_t hash_to_prime(uint32_t _index)
{
  int j = 0;
  
  while(true)
  {
    uint32_t _p = sha_to_int32(_index, j);
    if(isPrime(_p, 1)){
      printf("number:%"PRIu64"\n", _p);
      return _p;
    }
    j=j+1;
  }
}

 void BubbleSort(uint32_t a[], int array_size)
 {
 int i, j;
 uint32_t temp;
   for (i = 0; i < (array_size - 1); ++i)
   {
      for (j = 0; j < array_size - 1 - i; ++j )
      {
         if (a[j] > a[j+1])
         {
            temp = a[j+1];
            a[j+1] = a[j];
            a[j] = temp;
         }
      }
   }
 }  

static void
highlevel_unsorted()
{
    uint32_t in[LEN] = {0};
    uint8_t out[512];

    for (int i=0; i<LEN; i++)
        in[i] = hash_to_prime(i);
    
    printf("%u, %u\n", in[1], in[2]);
    BubbleSort(in, 1000);
    printf("%u, %u\n", in[1], in[2]);

    uint32_t size = for_compressed_size_sorted(&in[0], LEN);

    printf("compressed %u primes (%u bytes) into %u bytes\n", LEN, LEN * 4, size);
    //printf("largest number generated: %u \n", in[LEN-1]);

}


int main()
{
    highlevel_unsorted();
    read_ints("list.txt");
    //printf("prime: %u\n", hash_to_prime(4));
    return 0;
}
