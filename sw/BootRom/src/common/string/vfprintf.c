#include "string.h"
#include "vfprintf.h"
inline void strrev(char *dest, char *src);
int vsprintf(char *str, const char *ctl, void **args);

static const char hexnum[] = "0123456789ABCDEF";
#define BUF_MAX 1024

int vfprintf(const char *ctl, void **args, void (*printer)(char)) {
	char buf[BUF_MAX];
	
	int len = vsprintf(buf, ctl, args);
	char *p = buf;
	while( *p != '\0') {
		printer(*p++);
	}

	return len;
}

int sprintf(char *str, const char *ctl, ...){
	void **args = (void **)&ctl + 1;
	return vsprintf(str, ctl, args);
}

int vsprintf(char *str, const char *ctl, void **args){
	char *p, *q, *p_buf = str;
	
	char str_temp[30];	// enough space for a float value
	p = (char *)ctl;
	
	while(*p != '\0'){
		if(*p != '%'){
			*p_buf++ = *p++;
			continue;
		}
	
		int i, j = 0;
		q = p + 1;
		bool left_align = false;
		bool padding0 = false;
		bool set_precision = false;
		bool negative = false;
		int field_width = 0;
		int precision = 0;
		int len = 0;
		while(1){
			switch(*q){
			case 'u': case 'o': case 'x': case 'd':{
				uint32_t num = *(uint32_t *)(args++);
				if(num == 0){
					str_temp[0] = '0';
					str_temp[1] = '\0';
					len++;
				}
				else {
					if(*q == 'd' && (int)num < 0){
						num = -((int)num);
						negative = true;
					}
					
					int base = 0;
					switch(*q){
						case 'u': case 'd': base = 10; break;		
						case 'o': base = 8; break;
						case 'x': base = 16; break;
					}
					int temp;
					
					while(num){
						temp = num % base;
						str_temp[j++] = hexnum[temp];
						num /= base;
						len++;
					}
					str_temp[j] = '\0';
				}
				
				if(set_precision) padding0 = false;
				
				int max_len = precision > len ? precision : len;
				if(negative == true) max_len++;
				
				if(left_align == true){
					if(negative == true)
						*p_buf++ = '-';
					for(i = len; i < precision; i++)
						*p_buf++ = '0';
					strrev(p_buf, str_temp);
					p_buf += len;
					for(i = max_len; i < field_width; i++)
						*p_buf++ = ' ';
					*p_buf = '\0';
				}
				else{
					if(negative == false){
						for(i = max_len; i < field_width; i++)
							*p_buf++ = (padding0 ? '0' : ' ');
					}
					else{
						if(padding0 == true){
							*p_buf++ = '-';
							for(i = max_len; i < field_width; i++)
								*p_buf++ = '0';
						}
						else{
							for(i = max_len; i < field_width; i++)
								*p_buf++ = ' ';
							*p_buf++ = '-';
						}
						max_len--;
					}
					for(i = len; i < max_len; i++)
						*p_buf++ = '0';
					strrev(p_buf, str_temp);
					p_buf += len;
					*p_buf = '\0';
				}
				goto done;
			}
			
			case 'c':{
				if(left_align == true){
					*p_buf++ = *(char *)(args++);
					for(i = 1; i < field_width; i++)
						*p_buf++ = ' ';
				}
				else{
					for(i = 1; i < field_width; i++)
						*p_buf++ = ' ';
					*p_buf++ = *(char *)(args++);
				}
				goto done;
			}	
			case 's':{
				char *s = *(char **)(args++);
				// assert(s != NULL);
				int len = strlen(s);
				if(precision > 0 && precision < len)
					len = precision;
				if(left_align == true){
					strcpy(p_buf, s);
					p_buf += len;
					for(i = len; i < field_width; i++)
						*p_buf++ = ' ';
				}
				else{
					for(i = len; i < field_width; i++)
						*p_buf++ = ' ';
					strcpy(p_buf, s);
					p_buf += len;
				}
				goto done;
			}	
			case '-': 
				if(left_align == true) goto error;
				left_align = true;
				q++;
				break;
			case '0': padding0 = true; q++; break;
			case '.':
				if(set_precision == true) goto error;
				set_precision = true;
				q++;
				if(*q == '-'){
					q++;
					while(*q >= '0' && *q <= '9') q++;
					break;
				}
				
				while(*q >= '0' && *q <= '9'){
					precision *= 10;
					precision += *q - '0';
					q++;
				}
				break;
			case '%': *p_buf++ = '%'; goto done;
			case '\0': return 0;
			default:
				// setting field width
				if(*q >= '0' && *q <= '9'){
					do{
					field_width *= 10;
					field_width += *q - '0';
					q++;
					}while(*q >= '0' && *q <= '9');
					break;
				}
				
error:			while(p <= q) *p_buf++ = *p++;
				goto done;
			}
		}
done:	p = q + 1;
	}
	
	*p_buf = '\0';
	
	return strlen(str);
}

inline void strrev(char *dest, char *src){
	char *p = src;
	while(*p != '\0') p++;
	do{
		*dest++ = *(--p);
	}while(p > src);
	
	*dest = '\0';
}

void serial_printc(char ch);

void print_int(int n) {
	if(n == 0) {
		serial_printc('0');
		return;
	}

	char s[16];
	int i = 0;
	bool neg = false;
	if(n < 0){
		neg = true;
		n = -n;
	}

	while(n > 0) {
		s[i ++] = n % 10 + '0';
		n /= 10;
	}
	if(neg) {
		s[i ++] = '-';
	}
	for(i --; i >= 0; i --) {
		serial_printc(s[i]);
	}
	serial_printc('\n');
}

void print_hex(uint32_t n) {
	static const char digit[16] = "0123456789abcdef";
	char s[8];

	int i;
	for(i = 0; i < 8; i ++) {
		s[i] = digit[n & 15];
		n >>= 4;
	}
	for(i --; i >= 0; i --) {
		serial_printc(s[i]);
	}

	serial_printc('\n');
}
