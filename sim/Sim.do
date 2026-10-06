#----------------------------------*-tcl-*-
# Simulacion del banco de pruebas (sin preguntas, hasta el final del test)
#
# Uso (desde la carpeta sim/):
#   vsim -do Sim.do                                   FIFO propia, WIDTH=8, DEPTH=32
#   vsim -do "set PROFESOR 1; do Sim.do"              FIFO del profesor
#   vsim -do "set WIDTH 16; set DEPTH 16; do Sim.do"  otros parametros
#   vsim -do "set top FIFO_tb_v0; do Sim.do"          test dirigido del profesor
#
# Al terminar genera el informe HTML de cobertura en sim/covhtmlreport/.

# reload: recompila y vuelve a simular con la misma configuracion
proc reload {} {
  do Comp.do
  do Sim.do
}

if {![info exists top]}      {set top FIFO_tb}
if {![info exists WIDTH]}    {set WIDTH 8}
if {![info exists DEPTH]}    {set DEPTH 32}
if {![info exists PROFESOR]} {set PROFESOR 0}

if {$top eq "FIFO_tb"} {
  set gparams "-gDATA_WIDTH=$WIDTH -gDEPTH=$DEPTH -gFIFO_PROFESOR=$PROFESOR"
} else {
  set gparams ""
}

echo "Sim: top=$top $gparams"
eval vsim -voptargs=+acc -msgmode both -assertdebug -wlfdeleteonquit -onfinish stop $gparams work.${top}

echo "Sim: load wave-file(s)"
catch {do wave.do}
log -r /*

echo "Sim: run ..."
# Al llegar al $finish (o a un $stop) el script sigue con el informe de cobertura
onbreak {resume}
run -all

coverage report -html -output covhtmlreport -details -cvg -assert
echo "Informe HTML de cobertura: sim/covhtmlreport/index.html"
