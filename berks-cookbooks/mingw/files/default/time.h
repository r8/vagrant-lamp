/*
 * time.h
 *
 * Type definitions and function declarations relating to date and time.
 *
 * $Id: time.h,v ffe8d63c87e3 2015/05/18 12:49:39 keithmarshall $
 *
 * Written by Rob Savoye <rob@cygnus.com>
 * Copyright (C) 1997-2007, 2011, 2015, MinGW.org Project.
 *
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice, this permission notice, and the following
 * disclaimer shall be included in all copies or substantial portions of
 * the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OF OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */
#ifndef _TIME_H
#define _TIME_H

/* All the headers include this file. */
#include <_mingw.h>

/* Number of clock ticks per second. A clock tick is the unit by which
 * processor time is measured and is returned by 'clock'.
 */
#define CLOCKS_PER_SEC	((clock_t)(1000))
#define CLK_TCK 	CLOCKS_PER_SEC

#ifndef RC_INVOKED
/*
 * Some elements declared in time.h may also be required by other
 * header files, without necessarily including time.h itself; such
 * elements are declared in the local parts/time.h system header file.
 * Declarations for such elements must be selected prior to inclusion:
 */
#define __need_time_t
#define __need_struct_timespec
#include <parts/time.h>

/* time.h is also required to duplicate the following type definitions,
 * which are nominally defined in stddef.h
 */
#define __need_NULL
#define __need_wchar_t
#define __need_size_t
#include <stddef.h>

/* A type for measuring processor time in clock ticks; (no need to
 * guard this, since it isn't defined elsewhere).
 */
typedef long clock_t;

#ifndef _TM_DEFINED
/*
 * A structure for storing all kinds of useful information about the
 * current (or another) time.
 */
struct tm
{
	int	tm_sec;		/* Seconds: 0-59 (K&R says 0-61?) */
	int	tm_min;		/* Minutes: 0-59 */
	int	tm_hour;	/* Hours since midnight: 0-23 */
	int	tm_mday;	/* Day of the month: 1-31 */
	int	tm_mon;		/* Months *since* january: 0-11 */
	int	tm_year;	/* Years since 1900 */
	int	tm_wday;	/* Days since Sunday (0-6) */
	int	tm_yday;	/* Days since Jan. 1: 0-365 */
	int	tm_isdst;	/* +1 Daylight Savings Time, 0 No DST,
				 * -1 don't know */
};
#define _TM_DEFINED
#endif

_BEGIN_C_DECLS

_CRTIMP clock_t __cdecl __MINGW_NOTHROW	clock (void);
#if __MSVCRT_VERSION__ < 0x0800
_CRTIMP time_t __cdecl __MINGW_NOTHROW	time (time_t*);
_CRTIMP double __cdecl __MINGW_NOTHROW	difftime (time_t, time_t);
_CRTIMP time_t __cdecl __MINGW_NOTHROW	mktime (struct tm*);
#endif

/*
 * These functions write to and return pointers to static buffers that may
 * be overwritten by other function calls. Yikes!
 *
 * NOTE: localtime, and perhaps the others of the four functions grouped
 * below may return NULL if their argument is not 'acceptable'. Also note
 * that calling asctime with a NULL pointer will produce an Invalid Page
 * Fault and crap out your program. Guess how I know. Hint: stat called on
 * a directory gives 'invalid' times in st_atime etc...
 */
_CRTIMP char* __cdecl __MINGW_NOTHROW		asctime (const struct tm*);
#if __MSVCRT_VERSION__ < 0x0800
_CRTIMP char* __cdecl __MINGW_NOTHROW		ctime (const time_t*);
_CRTIMP struct tm*  __cdecl __MINGW_NOTHROW	gmtime (const time_t*);
_CRTIMP struct tm*  __cdecl __MINGW_NOTHROW	localtime (const time_t*);
#endif

_CRTIMP size_t __cdecl __MINGW_NOTHROW		strftime (char*, size_t, const char*, const struct tm*);

#ifndef __STRICT_ANSI__

extern _CRTIMP void __cdecl __MINGW_NOTHROW	_tzset (void);

#ifndef _NO_OLDNAMES
extern _CRTIMP void __cdecl __MINGW_NOTHROW	tzset (void);
#endif

_CRTIMP char* __cdecl __MINGW_NOTHROW	_strdate(char*);
_CRTIMP char* __cdecl __MINGW_NOTHROW	_strtime(char*);

/* These require newer versions of msvcrt.dll (6.10 or higher). */
#if __MSVCRT_VERSION__ >= 0x0601
_CRTIMP __time64_t __cdecl __MINGW_NOTHROW  _time64( __time64_t*);
_CRTIMP __time64_t __cdecl __MINGW_NOTHROW  _mktime64 (struct tm*);
_CRTIMP char* __cdecl __MINGW_NOTHROW _ctime64 (const __time64_t*);
_CRTIMP struct tm*  __cdecl __MINGW_NOTHROW _gmtime64 (const __time64_t*);
_CRTIMP struct tm*  __cdecl __MINGW_NOTHROW _localtime64 (const __time64_t*);
#endif /* __MSVCRT_VERSION__ >= 0x0601 */

/* These require newer versions of msvcrt.dll (8.00 or higher). */
#if __MSVCRT_VERSION__ >= 0x0800
_CRTIMP __time32_t __cdecl __MINGW_NOTHROW	_time32 (__time32_t*);
_CRTIMP double	   __cdecl __MINGW_NOTHROW	_difftime32 (__time32_t, __time32_t);
_CRTIMP double	   __cdecl __MINGW_NOTHROW	_difftime64 (__time64_t, __time64_t);
_CRTIMP __time32_t __cdecl __MINGW_NOTHROW	_mktime32 (struct tm*);
_CRTIMP __time32_t __cdecl __MINGW_NOTHROW	_mkgmtime32 (struct tm*);
_CRTIMP __time64_t __cdecl __MINGW_NOTHROW	_mkgmtime64 (struct tm*);
_CRTIMP char*	   __cdecl __MINGW_NOTHROW	_ctime32 (const __time32_t*);
_CRTIMP struct tm* __cdecl __MINGW_NOTHROW	_gmtime32 (const __time32_t*);
_CRTIMP struct tm* __cdecl __MINGW_NOTHROW	_localtime32 (const __time32_t*);
#ifndef _USE_32BIT_TIME_T
_CRTALIAS time_t	   __cdecl __MINGW_NOTHROW	time (time_t* _v)		  { return(_time64 (_v)); }
_CRTALIAS double	   __cdecl __MINGW_NOTHROW	difftime (time_t _v1, time_t _v2) { return(_difftime64 (_v1,_v2)); }
_CRTALIAS time_t	   __cdecl __MINGW_NOTHROW	mktime (struct tm* _v)		  { return(_mktime64 (_v)); }
_CRTALIAS time_t	   __cdecl __MINGW_NOTHROW	_mkgmtime (struct tm* _v)	  { return(_mkgmtime64 (_v)); }
_CRTALIAS char*		   __cdecl __MINGW_NOTHROW	ctime (const time_t* _v)	  { return(_ctime64 (_v)); }
_CRTALIAS struct tm*	   __cdecl __MINGW_NOTHROW	gmtime (const time_t* _v)	  { return(_gmtime64 (_v)); }
_CRTALIAS struct tm*	   __cdecl __MINGW_NOTHROW	localtime (const time_t* _v)	  { return(_localtime64 (_v)); }
#else
_CRTALIAS time_t	   __cdecl __MINGW_NOTHROW	time (time_t* _v)		  { return(_time32 (_v)); }
_CRTALIAS double	   __cdecl __MINGW_NOTHROW	difftime (time_t _v1, time_t _v2) { return(_difftime32 (_v1,_v2)); }
_CRTALIAS time_t	   __cdecl __MINGW_NOTHROW	mktime (struct tm* _v)		  { return(_mktime32 (_v)); }
_CRTALIAS time_t	   __cdecl __MINGW_NOTHROW	_mkgmtime (struct tm* _v)	  { return(_mkgmtime32 (_v)); }
_CRTALIAS char*		   __cdecl __MINGW_NOTHROW	ctime (const time_t* _v)	  { return(_ctime32 (_v)); }
_CRTALIAS struct tm*	   __cdecl __MINGW_NOTHROW	gmtime (const time_t* _v)	  { return(_gmtime32 (_v)); }
_CRTALIAS struct tm*	   __cdecl __MINGW_NOTHROW	localtime (const time_t* _v)	  { return(_localtime32 (_v)); }
#endif /* !_USE_32BIT_TIME_T */
#endif /* __MSVCRT_VERSION__ >= 0x0800 */

/* _daylight: non zero if daylight savings time is used.
 * _timezone: difference in seconds between GMT and local time.
 * _tzname: standard/daylight savings time zone names (an array with two
 *          elements).
 */
#ifdef __MSVCRT__

/* These are for compatibility with pre-VC 5.0 suppied MSVCRT. */
extern _CRTIMP int* __cdecl __MINGW_NOTHROW	__p__daylight (void);
extern _CRTIMP long* __cdecl __MINGW_NOTHROW	__p__timezone (void);
extern _CRTIMP char** __cdecl __MINGW_NOTHROW	__p__tzname (void);

__MINGW_IMPORT int	_daylight;
__MINGW_IMPORT long	_timezone;
__MINGW_IMPORT char 	*_tzname[2];

#else /* not __MSVCRT (ie. crtdll) */

#ifndef __DECLSPEC_SUPPORTED

extern int*	_imp___daylight_dll;
extern long*	_imp___timezone_dll;
extern char**	_imp___tzname;

#define _daylight	(*_imp___daylight_dll)
#define _timezone	(*_imp___timezone_dll)
#define _tzname		(*_imp___tzname)

#else /* __DECLSPEC_SUPPORTED */

__MINGW_IMPORT int	_daylight_dll;
__MINGW_IMPORT long	_timezone_dll;
__MINGW_IMPORT char*	_tzname[2];

#define _daylight	_daylight_dll
#define _timezone	_timezone_dll

#endif /* __DECLSPEC_SUPPORTED */
#endif /* ! __MSVCRT__ */
#endif /* ! __STRICT_ANSI__ */

#ifndef _NO_OLDNAMES
#ifdef __MSVCRT__

/* These go in the oldnames import library for MSVCRT.
 */
__MINGW_IMPORT int	daylight;
__MINGW_IMPORT long	timezone;
__MINGW_IMPORT char 	*tzname[2];

#else /* ! __MSVCRT__ */
/*
 * CRTDLL is royally messed up when it comes to these macros.
 * TODO: import and alias these via oldnames import library instead
 * of macros.
 */
#define daylight        _daylight
/*
 * NOTE: timezone not defined as a macro because it would conflict with
 * struct timezone in sys/time.h.  Also, tzname used to a be macro, but
 * now it's in moldname.
 */
__MINGW_IMPORT char 	*tzname[2];

#endif /* ! __MSVCRT__ */
#endif /* ! _NO_OLDNAMES */

#ifndef _WTIME_DEFINED
/* wide function prototypes, also declared in wchar.h */
#ifndef __STRICT_ANSI__
#ifdef __MSVCRT__
_CRTIMP wchar_t* __cdecl __MINGW_NOTHROW	_wasctime(const struct tm*);
#if __MSVCRT_VERSION__ < 0x0800
_CRTIMP wchar_t* __cdecl __MINGW_NOTHROW	_wctime(const time_t*);
#endif
_CRTIMP wchar_t* __cdecl __MINGW_NOTHROW	_wstrdate(wchar_t*);
_CRTIMP wchar_t* __cdecl __MINGW_NOTHROW	_wstrtime(wchar_t*);
#if __MSVCRT_VERSION__ >= 0x0601
_CRTIMP wchar_t* __cdecl __MINGW_NOTHROW	_wctime64 (const __time64_t*);
#endif
#if __MSVCRT_VERSION__ >= 0x0800
_CRTIMP wchar_t* __cdecl __MINGW_NOTHROW	_wctime32 (const __time32_t*);
#ifndef _USE_32BIT_TIME_T
_CRTALIAS wchar_t* __cdecl __MINGW_NOTHROW	_wctime (const time_t* _v) { return(_wctime64 (_v)); }
#else
_CRTALIAS wchar_t* __cdecl __MINGW_NOTHROW	_wctime (const time_t* _v) { return(_wctime32 (_v)); }
#endif
#endif /* __MSVCRT_VERSION__ >= 0x0800 */
#endif /*  __MSVCRT__ */
#endif /* __STRICT_ANSI__ */
_CRTIMP size_t __cdecl __MINGW_NOTHROW		wcsftime (wchar_t*, size_t, const wchar_t*, const struct tm*);
#define _WTIME_DEFINED
#endif /* _WTIME_DEFINED */

_END_C_DECLS

/* -------------------------------------------------------------------
 * CHEF PATCHES
 *
 * PROVIDE clock_gettime ETC. IN time.h FOR POSIX COMPLIANCE.
 *
 * This code was copied from the 64-bit TDM gcc compiler headers.  It
 * is here to allow certain libraries (like libxslt) to compile
 * because they assume that they are only going to be built on a POSIX
 * system.  The C99 standards do not require that these functions be
 * available but most POSIX systems provide them unless strict x-play
 * compatibility is requested.
 *
 * On windows, configure could possibly identify that these functions
 * are unavailable but since it tests for function availability to
 * attempting to link a binary with said functions, these tests
 * succeed with our TDM mingw runtime (because we indeed support these
 * posix compatibility methods).  Hence we pretend like we are a POSIX
 * compliant system and export these methods.
 */

/* POSIX 2008 says clock_gettime and timespec are defined in time.h header,
   but other systems - like Linux, Solaris, etc - tend to declare such
   recent extensions only if the following guards are met.  */
#if !defined(IN_WINPTHREAD) && \
	((!defined(_STRICT_STDC) && !defined(__XOPEN_OR_POSIX)) || \
	 (_POSIX_C_SOURCE > 2) || defined(__EXTENSIONS__))
#include <pthread_time.h>
#endif

/* END OF CHEF PATCHES
 * -------------------------------------------------------------------
 */

#endif /* ! RC_INVOKED */
#endif /* ! _TIME_H: $RCSfile: time.h,v $: end of file */
