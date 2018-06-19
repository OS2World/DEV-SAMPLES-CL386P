/* define NULL pointer value */

#define NULL	0

/* min and max macros */

#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))

typedef int (_stdcall * onexit_t)(void);

typedef unsigned int size_t;

typedef struct _div_t {
	int quot;
	int rem;
} div_t;

typedef struct _ldiv_t {
	long quot;
	long rem;
} ldiv_t;

/* ANSI function prototypes */

void          _stdcall abort (void);
int           _stdcall abs (int);
int           _stdcall atexit (void (_stdcall *)(void));
double        _stdcall atof (const char *);
int           _stdcall atoi (const char *);
long          _stdcall atol (const char *);
void *        _stdcall bsearch (const void *, const void *, size_t, size_t,
	                     int (_stdcall *)(const void *, const void *));
void *        _stdcall calloc (size_t, size_t);
div_t         _stdcall div (int, int);
void          _stdcall exit (int);
void          _stdcall free (void *);
char *        _stdcall getenv (const char *);
long          _stdcall labs (long);
ldiv_t        _stdcall ldiv (long, long);
void *        _stdcall malloc (size_t);
void *        _stdcall memchr (const void *, int, size_t);
int           _stdcall memcmp (const void *, const void *, size_t);
void *        _stdcall memcpy (void *, const void *, size_t);
void *        _stdcall memmove (void *, const void *, size_t);
void *        _stdcall memset (void *, int, size_t);
void          _stdcall perror (const char *);
void          _stdcall qsort (void *, size_t, size_t, int (_stdcall *)(const void *,
	                     const void *));
int           _stdcall rand (void);
void *        _stdcall realloc (void *, size_t);
void          _stdcall srand (unsigned int);
char *        _stdcall strcat (char *, const char *);
char *        _stdcall strchr (const char *, int);
int           _stdcall strcmp (const char *, const char *);
int           _stdcall strcoll (const char *, const char *);
char *        _stdcall strcpy (char *, const char *);
size_t        _stdcall strcspn (const char *, const char *);
char *        _stdcall strerror (int);
size_t        _stdcall strlen (const char *);
char *        _stdcall strncat (char *, const char *, size_t);
int           _stdcall strncmp (const char *, const char *, size_t);
char *        _stdcall strncpy (char *, const char *, size_t);
char *        _stdcall strpbrk (const char *, const char *);
char *        _stdcall strrchr (const char *, int);
size_t        _stdcall strspn (const char *, const char *);
char *        _stdcall strstr (const char *, const char *);
double        _stdcall strtod (const char *, char **);
char *        _stdcall strtok (char *, const char *);
long          _stdcall strtol (const char *, char **, int);
unsigned long _stdcall strtoul (const char *, char **, int);
size_t        _stdcall strxfrm (char *, const char *, size_t);
int           _stdcall system (const char *);
int           _stdcall tolower (int);
int           _stdcall toupper (int);

/* non-ANSI function prototypes */

char *        _stdcall itoa (int, char *, int);
char *        _stdcall ltoa (long, char *, int);
char *        _stdcall ultoa (unsigned long, char *, int);


