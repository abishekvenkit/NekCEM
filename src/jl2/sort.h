#ifndef SORT_H
#define SORT_H

#if !defined(TYPES_H) || !defined(MEM_H)
#warning "sort.h" requires "types.h" and "mem.h"
#endif

/*------------------------------------------------------------------------------
  
  Sort
  
  O(n) stable sort with good performance for all n

  sortv     (uint  *out,  const uint  *A, uint n, uint stride,  buffer *buf)
  sortv_long(ulong *out,  const ulong *A, uint n, uint stride,  buffer *buf)

  sortp     (buffer *buf, int perm_start,  const uint  *A, uint n, uint stride)
  sortp_long(buffer *buf, int perm_start,  const ulong *A, uint n, uint stride)

  A, n, stride : specifices the input (stride is in bytes!)
  out : the sorted values on output

  For the value sort,
    A and out may alias (A == out) exactly when stride == sizeof(T)

  For the permutation sort,
    the permutation can be both input (when start_perm!=0) and output,
    following the convention that it is always at the start of the buffer buf;
    the buffer will be expanded as necessary to accomodate the permutation
    and the required scratch space

  ----------------------------------------------------------------------------*/

#define sortv_ui  PREFIXED_NAME(sortv_ui)
#define sortv_ul  PREFIXED_NAME(sortv_ul)
#define sortv_ull PREFIXED_NAME(sortv_ull)
#define sortp_ui  PREFIXED_NAME(sortp_ui)
#define sortp_ul  PREFIXED_NAME(sortp_ul)
#define sortp_ull PREFIXED_NAME(sortp_ull)

#define sortv TYPE_LOCAL(sortv_ui,sortv_ul,sortv_ull)
#define sortp TYPE_LOCAL(sortp_ui,sortp_ul,sortp_ull)
#define sortv_long TYPE_GLOBAL(sortv_ui,sortv_ul,sortv_ull)
#define sortp_long TYPE_GLOBAL(sortp_ui,sortp_ul,sortp_ull)

void sortv_ui(unsigned *out, const unsigned *A, uint n, unsigned stride,
              buffer *buf);
void sortv_ul(unsigned long *out,
              const unsigned long *A, uint n, unsigned stride,
              buffer *buf);
uint *sortp_ui(buffer *buf, int start_perm,
               const unsigned *A, uint n, unsigned stride);
uint *sortp_ul(buffer *buf, int start_perm,
               const unsigned long *A, uint n, unsigned stride);
#if defined(USE_LONG_LONG) || defined(GLOBAL_LONG_LONG)
void sortv_ull(unsigned long long *out,
               const unsigned long long *A, uint n, unsigned stride,
               buffer *buf);
uint *sortp_ull(buffer* buf, int start_perm,
                const unsigned long long *A, uint n, unsigned stride);
#endif

#endif