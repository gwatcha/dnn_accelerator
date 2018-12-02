set_global_assignment -entity "dnn_accel_system" -library "lib_dnn_accel_system" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "dnn_accel_system" -library "lib_dnn_accel_system" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "dnn_accel_system" -library "lib_dnn_accel_system" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_dnn_accel_system" -name SPD_FILE [file join $::quartus(sip_path) "../dnn_accel_system.spd"]
set_global_assignment -library "lib_dnn_accel_system" -name MISC_FILE [file join $::quartus(sip_path) "../../dnn_accel_system.qsys"]

set_global_assignment -library "lib_dnn_accel_system" -name MISC_FILE [file join $::quartus(sip_path) "dnn_accel_system.v"]
