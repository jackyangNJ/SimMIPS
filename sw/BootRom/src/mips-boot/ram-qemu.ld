ENTRY(_reset)
SECTIONS
{
    . = 0x81000000;
    .text : { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) }
    . = . + 0x1000; /* 4kB of stack memory */
    stack_top = .;
}