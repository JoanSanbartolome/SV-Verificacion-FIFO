#----------------------------------*-tcl-*-
# Simulacion con inyeccion de errores
# Uso: vsim -do "set ERR FLAG; do SimErr.do"
# Modos: DATO, FLAG, USEDW, ESTADO

if {![info exists ERR]} { set ERR FLAG }
set top FIFO_tb

echo "Sim: inyeccion de errores, modo $ERR"
vsim -voptargs=+acc -msgmode both -assertdebug -wlfdeleteonquit -onfinish stop work.${top} work.FIFO_inyeccion_bind +ERR=$ERR

catch {do wave.do}
log -r /*
run -all