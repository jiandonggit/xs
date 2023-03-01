set search_path [concat \
    $DESIGN_PATH \
    $MEM_LIB_PATH \
    $STD_LIB_PATH \
    $IP_LIB_PATH \
    $IO_LIB_PATH \
    ]
set link_library [concat * \
    $STD_LIBS \
    $MEM_LIBS \
    $IP_LIBS \
    $IO_LIBS \
    ]

