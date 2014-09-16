#ifndef _VFPRINTF_
#define _VFPRINTF_

	int vfprintf(const char *ctl, void **args, void (*printer)(char));
#endif