#include "string.h"
int strlen(char* p) {
    char* q = p;
    while (*q != '\0') q++;
    return q - p;
}

char* strcpy(char* dest, char* src) {
    char *p = dest;
    while (*src != '\0') *p++ = *src++;
    *p = '\0';
    return dest;
}

char* strcat(char* dest, char* src) {
    char *p = dest + strlen(dest);
    while (*src != '\0') *p++ = *src++;
    *p = '\0';
    return dest;
}

char* strncpy(char* dest, char* src, int max_len) {
    char *p = dest;
    while (*src != '\0' && max_len-- > 0) *p++ = *src++;
    *p = '\0';
    return dest;
}

char* strncat(char* dest, char* src, int max_len) {
    char *p = dest + strlen(dest);
    while (*src != '\0' && max_len-- > 0) *p++ = *src++;
    *p = '\0';
    return dest;
}

int strcmp(char* s1, char* s2) {
    int diff;
    while (*s1 != '\0' && *s2 != '\0') {
        diff = *s1++ - *s2++;
        if (diff != 0)
            return diff;
    }
    return *s1 - *s2;
}

int strncmp(char* s1, char* s2, int max_len) {
    int diff;
    while (*s1 != '\0' && *s2 != '\0' && max_len > 0) {
        diff = *s1++ - *s2++;
        if (diff != 0)
            return diff;
        max_len--;
    }
    if (max_len == 0)
        return 0;
    return *s1 - *s2;
}

char* strchr(char* s1, int c) {
    char *p = s1;
    while (*p != '\0') {
        if ((int) *p == c) return p;
        p++;
    }
    return 0;
}

void* memcpy(void *dest, void *src, int len) {
    uint8_t *p = dest;
    while (len--) *p++ = *(uint8_t *) src++;
    return dest;
}

void* memcpyl(void *dest, void *src, int len) {
    uint32_t *p = dest, *q = src;
    while (len--) *p++ = *q++;
    return dest;
}

void* memset(void *dest, uint8_t c, int len) {
    uint8_t *p = dest;
    while (len--) *p++ = c;
    return dest;
}

void* memsetw(void *dest, uint16_t c, int len) {
    uint16_t *p = dest;
    while (len--) *p++ = c;
    return dest;
}

int memcmp(void *dest, void *src, int len) {
    int i;
    for (i = 0; i < len; i++) {
        if (((char*) dest)[i] != ((char*) src)[i])
            return ((char*) dest)[i] - ((char*) src)[i];
    }
    return 0;
}

//the string p must contains only numbers

int str2int(char *p, int *num) {
    *num = 0;
    while (*p != '\0') {
        if (*p > '9' || *p < '0')
            return -1;
        *num = *num * 10 + *p - '0';
        p++;
    }
    return 0;
}

void tolower(char * str) {
    while (*str) {
        if (*str >= 'A' && *str <= 'Z')
            *str -= 'A' - 'a';
        str++;
    }
}

void toupper(char * str) {
    while (*str) {
        if (*str >= 'a' && *str <= 'z')
            *str -= 'a' - 'A';
        str++;
    }
}

int str2hex(char* str) {
    int num = 0;
    tolower(str);
    if (str[0] == '0' && str[1] == 'x') {
        str += 2;
        while (*str) {
            if (*str >= '0' && *str <= '9')
                num = (num << 4) + *str - '0';
            else
                if (*str >= 'a' && *str <= 'f')
                num = (num << 4) + *str - 'a' + 10;
            else
                return 0;
            str++;
        }
        return num;
    } else
        return 0;
}

void int2str(int num, char *p) {
    if (num < 0) {
        *p++ = '-';
        num = -num;
    } else if (num == 0) {
        *p++ = '0';
        *p = '\0';
        return;
    }

    int len = 0;
    int temp = num;
    while (temp > 0) {
        temp /= 10;
        len++;
    }
    *((p += len - 1) + 1) = '\0';
    while (len-- > 0) {
        *p-- = num % 10 + '0';
        num /= 10;
    }
}
