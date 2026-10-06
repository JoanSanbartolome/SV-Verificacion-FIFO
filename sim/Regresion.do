#----------------------------------*-tcl-*-
# Regresion: el mismo test sobre las dos FIFOs y con tres combinaciones de
# parametros. Cada simulacion deja su log en reg_<fifo>_<W>x<D>.log y al
# final se imprime un resumen con la linea RESULTADO del scoreboard.
#
# Uso (desde la carpeta sim/):
#   vsim -c -do Regresion.do        (en consola; o "do Regresion.do" en la GUI)

do Comp.do

# Al llegar al $finish de cada simulacion, el script sigue con la siguiente
onbreak {resume}

#        fifo     FIFO_PROFESOR WIDTH DEPTH
set casos {
  {propia   0  8 32}
  {propia   0 16 16}
  {propia   0  4 64}
  {profesor 1  8 32}
  {profesor 1 16 16}
  {profesor 1  4 64}
}

set resumen {}
foreach caso $casos {
  lassign $caso nombre prof w d
  set log "reg_${nombre}_${w}x${d}.log"
  echo "=== Regresion: FIFO $nombre, WIDTH=$w, DEPTH=$d ==="
  transcript file $log
  vsim -msgmode both -onfinish stop -gDATA_WIDTH=$w -gDEPTH=$d -gFIFO_PROFESOR=$prof work.FIFO_tb
  run -all
  quit -sim
  transcript file transcript

  # Busca en el log la linea RESULTADO del informe del scoreboard
  set res "sin resultado (revisar $log)"
  if {[file exists $log]} {
    set fp [open $log r]
    foreach linea [split [read $fp] "\n"] {
      if {[regexp {RESULTADO: (.*)$} $linea -> r]} { set res $r }
    }
    close $fp
  }
  lappend resumen [format "  FIFO %-9s %2d x %-3d  %s" $nombre $w $d $res]
}

echo "==================== RESUMEN DE LA REGRESION ===================="
foreach l $resumen { echo $l }
echo "================================================================="

if {[batch_mode]} { quit -f }
