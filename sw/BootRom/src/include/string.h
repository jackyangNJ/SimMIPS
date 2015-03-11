#ifndef __STRING_H__
#define __STRING_H__
#include "types.h"

int strlen(char* p);
char* strcpy(char* dest, char* src);
char* strcat(char* dest, char* src);
int strcmp(char* st, char* s2);
char* strncpy(char* dest, char* src, int max_len);
char* strncat(char* dest, char* src, int max_len);
int strncmp(char* st, char* s2, int max_len);
char* strchr(char* s1, int c);

void* memcpy(void *dest, void *src, int len);
void* memcpyl(void *dest, void *src, int len);
void* memcpyL(void *dest, void *src, int len);
void* memset(void *dest, uint8_t c, int len);
void* memsetw(void *dest, uint16_t c, int len);
void* memsetl(void *dest, int c, int len);
int memcmp(void *dest, void *src, int len);

void tolower(char * str);
void toupper(char * str);

int str2hex(char* str);

int str2int(char *p, int *num);
void int2str(int num, char *p);
#endif
