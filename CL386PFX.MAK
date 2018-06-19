bitware.lib : cl386pfx.obj
   lib bitware -+cl386pfx;

cl386pfx.obj : cl386pfx.asm
   masm386 /p /l /ml /n cl386pfx.asm,,;



