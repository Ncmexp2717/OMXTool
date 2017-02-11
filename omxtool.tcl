#!/bin/sh
#\
exec wish "$0" ${1+"$@"}
#@(#) OMXTool.tcl Ver. 1.4 - graphical utility tool for OpenMX.
#@(#) Copyright (C), 2015-2017, Naoya Yamaguchi.
#@(#) This software includes the work that is distributed
#@(#) in version 3 of the GPL (GPLv3).
#@(#)
#@(#) Log:
#@(#)    2015/07/10 Ver. alpha-1 Written by Naoya Yamaguchi.
#@(#)    2015/07/13 Ver. alpha-2 Written by Naoya Yamaguchi.
#@(#)    2015/07/15 Ver. alpha-3 Written by Naoya Yamaguchi.
#@(#)    2015/07/16 Ver. alpha-4 Written by Naoya Yamaguchi.
#@(#)    2015/08/24 Ver. alpha-5 Written by Naoya Yamaguchi.
#@(#)    2015/11/12 Ver. beta-1 Written by Naoya Yamaguchi.
#@(#)    2016/03/17 Ver. alpha-6 Written by Naoya Yamaguchi.
#@(#)    2016/06/11 Ver. 1.0 Released by Naoya Yamaguchi.
#@(#)    2016/08/19 Ver. 1.1 Released by Naoya Yamaguchi.
#@(#)    2016/09/23 Ver. 1.2 Released by Naoya Yamaguchi.
#@(#)    2016/10/01 Ver. 1.2.1 Modified by Naoya Yamaguchi.
#@(#)    2016/10/04 Ver. 1.2.2 Modified by Naoya Yamaguchi.
#@(#)    2016/10/18 Ver. 1.2.3 Modified by Naoya Yamaguchi.
#@(#)    2016/12/09 Ver. 1.2.4 Modified by Naoya Yamaguchi.
#@(#)    2016/12/17 Ver. 1.3 Released by Naoya Yamaguchi.
#@(#)    2016/12/18 Ver. 1.3.1 Modified by Naoya Yamaguchi.
#@(#)    2017/01/02 Ver. 1.3.2 Modified by Naoya Yamaguchi.
#@(#)    2017/01/15 Ver. 1.4 Released by Naoya Yamaguchi.
#@(#)                 (renaming 'openmx.tcl' 'OMXTool.tcl')
#@(#)    2017/02/11 Ver. 1.4.1 Modified by Naoya Yamaguchi.
#@(#)
#@(#) Usage:
#@(#)    ./OMXTool.tcl (&)
#@(#)
#@(#) Description:
#@(#)    This script provides graphical utilities for OpenMX.
#@(#)

proc status {} {
  set stat ""
  if {![catch {exec which qstat}]} {
    if {![catch {set stat [exec qstat -T | grep $::env(USER)]}]} {
    } elseif {![catch {exec which point}]} {
      set stat [exec point]
    } else {
      set stat [exec qstat]
    }
  } elseif {![catch {exec pjstat}]} {
    set stat [exec pjstat]
  }
  return $stat
}
proc status1 {} {
  set stat ""
  catch {set stat [exec ps -fu $::env(USER) | grep "reload\\.exp"]}
  return $stat
}
proc load_file {} {
  global dir path
  set path [tk_getOpenFile -initialdir $dir -filetypes {{{Band Data} {.Band}}}]
  if {$path ne ""} {
    set dir [file dirname $path]
  }
}
proc bandgap {} {
  global dir path
  set fp [open $path.BANDDAT1]
  while {[gets $fp data] >= 0} {
    if {[lindex $data 0] == 0.000000} {break}
  }
  while {[gets $fp data] >= 0} {
    set ene [lindex $data 1]
    if {$ene > 0} {
      if {![info exists cmin] || $ene < $cmin} {
	set cmin $ene
      }
    } elseif {![info exists vmax] || $ene > $vmax} {
      set vmax $ene
    }
  }
  return [expr $cmin - $vmax]
}
proc band_close {win} {
  global gp
  destroy .t$win
  close [lindex $gp $win]
}
#
# The function 'bandgnu' is based on 'bandgnu13.c', a postprocessing tool of OpenMX written by H. Kino.
#
proc bandgnu {argc argv} {
  array set Unit0 {0 27.21138505 1 1.0}
  array set Unitname0 {0 eV 1 Hartree}
  set iunit 0
  set Unit $Unit0($iunit)
  set Unitname $Unitname0($iunit)
  set fp [open [lindex $argv 0] r]
  gets $fp data
  scan $data "%d %d %lf" maxneig mspin ChemP
  gets $fp data
  scan $data "%lf %lf %lf %lf %lf %lf %lf %lf %lf" rtv(1)(1) rtv(1)(2) rtv(1)(3) rtv(2)(1) rtv(2)(2) rtv(2)(3) rtv(3)(1) rtv(3)(2) rtv(3)(3)
  gets $fp data
  scan $data "%d" nkpath
  set m_perpath 0
  for {set i 1} {$i<=$nkpath} {incr i} {
    gets $fp data
    scan $data "%d %lf %lf %lf %lf %lf %lf %s %s" n_perpath($i) kpath11($i)(1)(1) kpath($i)(1)(2) kpath($i)(1)(3) kpath($i)(2)(1) kpath($i)(2)(2) kpath($i)(2)(3) kname($i)(1) kname($i)(2)
    if {$kname($i\)\(1) eq "G"} {
      set kname($i)(1) "{/Symbol G}"
    }
    if {$kname($i\)\(2) eq "G"} {
      set kname($i)(2) "{/Symbol G}"
    }
  }
  set meig $maxneig
  if {$argc==3} {
    set ymin [expr {min([lindex $argv 1], [lindex $argv 2])/$Unit+$ChemP}]
    set ymax [expr {max([lindex $argv 1], [lindex $argv 2])/$Unit+$ChemP}]
    set lmin $maxneig
    set lmax 1
  } else {
    set ymin 100000.0
    set ymax -100000.0
  }
  for {set ik 1} {$ik<=$nkpath} {incr ik} {
    set ikm1 [expr {$ik-1}]
    for {set i_perpath 1} {$i_perpath<=$n_perpath($ik)} {incr i_perpath} {
      set i_perpathm1 [expr {$i_perpath-1}]
      for {set spin 0} {$spin<=$mspin} {incr spin} {
	gets $fp data
	scan $data "%d %lf %lf %lf" n1 vk(1) vk(2) vk(3)
	for {set i 1} {$i<=3} {incr i} {
	  set v($i) 0.0
	  for {set j 1} {$j<=3} {incr j} {
	    set v($i) [expr {$v($i)+$vk($j)*$rtv($j\)\($i)}]
	  }
	}
	for {set i 1} {$i<=3} {incr i} {
	  set vk($i) $v($i)
	}
	if {$i_perpath==1} {
	  if {$ik==1} {
	    set tmp 0.0
	    lappend klinel 0.0
	  } else {
	    lappend klinel $tmp
	  }
	} else {
	  set vkmovk1 [expr {$vk(1)-$ovk($spin\)\(1)}]
	  set vkmovk2 [expr {$vk(2)-$ovk($spin\)\(2)}]
	  set vkmovk3 [expr {$vk(3)-$ovk($spin\)\(3)}]
	  set tmp [expr {$tmp+sqrt($vkmovk1*$vkmovk1+$vkmovk2*$vkmovk2+$vkmovk3*$vkmovk3)}]
	  lappend klinel $tmp
	}
	for {set i 1} {$i<=3} {incr i} {
	  set ovk($spin)($i) $vk($i)
	}
	if {$meig>$n1} {
	  set meig $n1
	}
	gets $fp data
	if {$argc==3} {
	  for {set lminm1 [expr {$lmin-1}]} {$lminm1>=0} {incr lminm1 -1} {
	    if {[lindex $data $lminm1]<$ymin} {
	      set lmin [expr {$lminm1+2}]
	      break
	    }
	  }
	  for {set lmaxm1 [expr {$lmax-1}]} {$lmaxm1<$meig} {incr lmaxm1} {
	    if {[lindex $data $lmaxm1]>$ymax} {
	      set lmax $lmaxm1
	      break
	    }
	  }
	} else {
	  if {$ymin>[lindex $data 0]} {
	    set ymin [lindex $data 0]
	  }
	  if {$ymax<[lindex $data end]} {
	    set ymax [lindex $data end]
	  }
	}
	set l 1
	foreach EI $data {
	  lappend EIGENl($spin)($l) $EI
	  incr l
	}
      }
    }
  }
  if {$argc!=3} {
    set lmin 1
    set lmax $meig
  }
  set ymax1 [expr {($ymax-$ymin)*1.1+$ymin}]
  set ymin1 [expr {-($ymax-$ymin)*1.1+$ymax}]
  close $fp
  for {set spin 0} {$spin<=$mspin} {incr spin} {
    set fnamedat1($spin) [file rootname [lindex $argv 0]].BANDDAT[expr {$spin+1}]
    set fp [open $fnamedat1($spin) w]
    set index $n_perpath(1)
    for {set ik 2} {$ik<=$nkpath} {incr ik} {
      set k 0
      set kl [lindex $klinel $index]
      for {set i 0} {$i<=10} {incr i} {
	set tmp [expr {(($ymin1-$ChemP)+($ymax1-$ymin1)*$i/10.0)*$Unit}]
	if {$tmp>0 && $k==0} {
	  puts $fp [format "%lf %lf" $kl 0.0]
	  set k 1
	}
	puts $fp [format "%lf %lf" $kl $tmp]
      }
      set index [expr {$index+$n_perpath($ik)}]
      puts $fp \n
    }
    for {set l $lmin} {$l<=$lmax} {incr l} {
      set i_perpath 1
      set ik 1
      foreach kl $klinel EI $EIGENl($spin\)\($l) {
	puts $fp [format "%lf %15.12f" $kl [expr {($EI-$ChemP)*$Unit}]]
	incr i_perpath
	if {$i_perpath>$n_perpath($ik)} {
	  set i_perpath 1
	  incr ik
	  puts $fp \n
	}
      }
    }
    close $fp
  }
  set fname [file rootname [lindex $argv 0]].GNUBAND
  set fp [open $fname w]
  puts $fp "set style data lines"
  puts $fp "set nokey"
  puts $fp "set zeroaxis"
  puts $fp "set ytics 1"
  puts $fp "set mytics 5"
  puts $fp [format "set xra \[%lf:%lf\]" [lindex $klinel 0] [lindex $klinel end]]
  if {$argc==3} {
    puts $fp [format "set yra \[%lf:%lf\]" [expr {min([lindex $argv 1], [lindex $argv 2])}] [expr {max([lindex $argv 1], [lindex $argv 2])}]]
  } else {
    puts $fp [format "set yra \[%lf:%lf\]" [expr {($ymin1-$ChemP)*$Unit}] [expr {($ymax1-$ChemP)*$Unit}]]
  }
  puts $fp "set ylabel \"$Unitname\""
  puts -nonewline $fp "set xtics ("
  for {set ik 1} {$ik<=$nkpath} {incr ik} {
    if {$ik==1} {
      set ticsname $kname($ik\)\(1)
      set index 0
    } else {
      if {$kname($ik\)\(1) eq $kname([expr {$ik-1}]\)\(2)} {
	set ticsname $kname($ik\)\(1)
      } else {
	set ticsname $kname([expr {$ik-1}]\)\(2),$kname(ik\)\(1)
      }
    }
    puts -nonewline $fp [format "\"%s\" %lf, " $ticsname [lindex $klinel $index]]
    set index [expr {$index+$n_perpath($ik)}]
  }
  puts $fp [format "\"%s\" %lf)" $kname($nkpath\)\(2) [lindex $klinel end]]
  puts -nonewline $fp "plot \"$fnamedat1(0)\""
  if {$mspin==1} {
    puts $fp ", \"$fnamedat1(1)\""
  } else {
    puts $fp ""
  }
  puts $fp "pause -1"
  close $fp
  return "$lmin $lmax $nkpath"
}
proc band {} {
  global rootPath dir path nwin gp yraMin yraMax fontSize bandgnuPath bandgnuMode bandgnuAE ylabel bandgnuColor bandgnuPreview bandgnuExport bandgnuEnhanced ratio ytics
  if {$bandgnuMode eq "C"} {
    if {$bandgnuPath eq ""} {
      set tmp [tk_getOpenFile -initialdir $dir -filetypes {{{source file} {bandgnu*.c}}} -title "Select a source file of 'bandgnu'"]
      if {$tmp ne ""} {
	set bandgnuPath $tmp
      } else {
	return
      }
    }
  }
  load_file
  if {$path ne ""} {
    cd $rootPath
    if {$bandgnuMode eq "C"} {
      if {![file exists $bandgnuPath]} {
	puts "Error: Check the path of 'bandgnu*.c'."
	puts [pwd]
	exit 1
      }
      set bandgnu [file rootname [file tail $bandgnuPath]]
      if {![file exists $bandgnu]} {
	exec gcc $bandgnuPath -lm -o $bandgnu
      }
      cd $dir
      set path [file tail $path]
      catch {exec $rootPath/$bandgnu $path}
    } else {
      cd $dir
      set path [file tail $path]
      set bandgnuList [bandgnu 3 "$path $yraMin $yraMax"]
      set lmin [lindex $bandgnuList 0]
      set lmax [lindex $bandgnuList 1]
      set nkpath [lindex $bandgnuList 2]
    }
    set path [file rootname $path]
    set gpath $path.GNUBAND
    if {$bandgnuMode eq "Tcl" && $bandgnuPreview} {
      eval [exec gnuplot << "
      \ \ se term tkcanvas
      \ \ se ou '.$path.tcl'
      \ \ load '$gpath'
      \ \ se size ratio $ratio
      \ \ se yr \[$yraMin:$yraMax\]
      \ \ se yl '$ylabel'
      \ \ se yti $ytics
      \ \ rep
      "]
    }
    set p [open |gnuplot w]
    fconfigure $p -buffering none
    puts $p "  set mouse"
    if {$bandgnuMode eq "Tcl"} {
      puts $p "  set term unknown"
    }
    if {$bandgnuEnhanced} {
      set terminal "x11 enhanced"
    } else {
      set terminal x11
    }
    set bandgnuExport "postscript eps"
    set fp [open $gpath r]
    while {[gets $fp txt] >= 0} {
      if {[string equal -length 5 $txt pause]} {
	puts $p "  se size ratio $ratio"
	puts $p "  se yr \[$yraMin:$yraMax\]"
	puts $p "  se yl '$ylabel'"
	puts $p "  se yti $ytics"
	puts $p "  se term $terminal"
	if {$bandgnuAE} {
	  puts $p "  se term $bandgnuExport enhanced color $fontSize"
	  puts $p "  se ou '$path.eps'"
	  puts $p "  rep"
	  puts $p "  se term $terminal"
	  puts $p "  se output"
	}
	if {$bandgnuMode eq "C"} {
	  puts $p "  rep"
	} elseif {$bandgnuPreview} {
	  source .$path.tcl
	  file delete .$path.tcl
	}
	toplevel .t$nwin
	wm title .t$nwin $dir/$gpath
	if {$bandgnuMode eq "C"} {
	  set gap [bandgap]
	} else {
	  set gap "not supported"
	}
	label .t$nwin.lgap -text "Bandgap = $gap \[eV\]"
	frame .t$nwin.fCommon
	button .t$nwin.fCommon.bexit -text Close -command "band_close $nwin"
	button .t$nwin.fCommon.bExport -text Export -command "
	set tmp \[tk_getSaveFile -initialdir $dir -filetypes {{{Encapsulated PostScript (EPS)} {*.eps}} {{Portable Document Format (PDF)} {*.pdf}} {{Portable Network Graphics (PNG)} {*.png}} {{Joint Photographic Experts Group (JPEG)} {*.jpeg}} {{Scalable Vector Graphics (SVG)} {*.svg}} {{Enhanced Metafile Format (EMF)} {*.emf}} {{Graphics Interchange Format (GIF)} {*.gif}}} -parent .t$nwin\]
	if {\$tmp eq \"\"} {return}
	set filetype \[file extension \$tmp]
	if {\$filetype eq \"eps\"} {
	set bandgnuExport {postscript eps}
	} elseif {\$filetype eq \"pdf\"} {
	set bandgnuExport pdf
	} elseif {\$filetype eq \"png\"} {
	set bandgnuExport png
	} elseif {\$filetype eq \"jpeg\"} {
	set bandgnuExport jpeg
	} elseif {\$filetype eq \"svg\"} {
	set bandgnuExport svg
	} elseif {\$filetype eq \"emf\"} {
	set bandgnuExport emf
	} elseif {\$filetype eq \"gif\"} {
	set bandgnuExport gif
	}
	puts $p \"  se term \$bandgnuExport enhanced color \$fontSize\"
	puts $p \"  se ou '\$tmp'\"
	puts $p \"  rep\"
	puts $p \"  se term $terminal\"
	puts $p \"  se ou\"
	"
	if {$bandgnuMode eq "Tcl" && $bandgnuPreview} {
	  canvas .t$nwin.c -bg $bandgnuColor
	  pack .t$nwin.c
	  gnuplot .t$nwin.c
	}
	if {$bandgnuMode eq "C"} {
	  pack .t$nwin.lgap
	} else {
	  frame .t$nwin.fGnuplot
	  button .t$nwin.fGnuplot.bGnuplot -text Gnuplot -command "puts $p \"  rep\""
	  frame .t$nwin.fBranch
	  spinbox .t$nwin.fBranch.sb -from $lmin -to $lmax -increment 1
	  button .t$nwin.fBranch.b -text Branch -command "
	  if {\[.t$nwin.fBranch.sb get\]>$lmax} {
	  .t$nwin.fBranch.sb set $lmax
	  } elseif {\[.t$nwin.fBranch.sb get\]<$lmin} {
	  .t$nwin.fBranch.sb set $lmin
	  }
	  puts $p \"  plot '$path.BANDDAT1', '$path.BANDDAT1' in \[expr {(\[.t$nwin.fBranch.sb get\]-$lmin+1)*$nkpath-1}\]:\[expr {(\[.t$nwin.fBranch.sb get\]-$lmin+2)*$nkpath-2}\] lw 3\"
	  "
	  label .t$nwin.fBranch.l -text "($lmin-$lmax)"
	  if {$bandgnuPreview} {
	    checkbutton .t$nwin.fGnuplot.cbBackground -text Background -variable BGColor -offvalue #FFFFFF -onvalue $bandgnuColor -command ".t$nwin.c configure -bg \$BGColor"
	    .t$nwin.fGnuplot.cbBackground select
	  }
	  pack .t$nwin.fGnuplot
	  if {$bandgnuPreview} {
	    pack .t$nwin.fGnuplot.bGnuplot .t$nwin.fGnuplot.cbBackground -side left
	  } else {
	    pack .t$nwin.fGnuplot.bGnuplot
	  }
	  pack .t$nwin.fBranch
	  pack .t$nwin.fBranch.sb .t$nwin.fBranch.l .t$nwin.fBranch.b -side left
	}
	pack .t$nwin.fCommon
	pack .t$nwin.fCommon.bExport .t$nwin.fCommon.bexit -side left
	incr nwin
      } else {
	puts $p $txt
      }
    }
    close $fp
    lappend gp $p
  }
}
proc saveSetting {} {
  global rootPath yraMax yraMin fontSize bandgnuPath bandgnuMode WD bandgnuAE ylabel bandgnuColor bandgnuPreview bandgnuExport bandgnuEnhanced ratio ytics
  set fprc [open $rootPath/.omxtoolrc w]
  puts $fprc "set yraMax {$yraMax}"
  puts $fprc "set yraMin {$yraMin}"
  puts $fprc "set fontSize {$fontSize}"
  puts $fprc "set bandgnuPath {$bandgnuPath}"
  puts $fprc "set bandgnuMode {$bandgnuMode}"
  puts $fprc "set WD {$WD}"
  puts $fprc "set bandgnuAE {$bandgnuAE}"
  puts $fprc "set ylabel {$ylabel}"
  puts $fprc "set bandgnuColor {$bandgnuColor}"
  puts $fprc "set bandgnuPreview {$bandgnuPreview}"
  puts $fprc "set bandgnuExport {$bandgnuExport}"
  puts $fprc "set bandgnuEnhanced {$bandgnuEnhanced}"
  puts $fprc "set ratio {$ratio}"
  puts $fprc "set ytics {$ytics}"
  close $fprc
}
proc openOption {} {
  toplevel .tOption
  wm title .tOption Option
  grab set .tOption
  frame .tOption.fYra
  label .tOption.fYra.l -text Yrange
  label .tOption.fYra.ll -text \[
  label .tOption.fYra.lc -text :
  label .tOption.fYra.lr -text \]
  entry .tOption.fYra.eMax -textvariable yraMax
  entry .tOption.fYra.eMin -textvariable yraMin
  frame .tOption.fFontSize
  label .tOption.fFontSize.l -text "Font Size"
  entry .tOption.fFontSize.e -textvariable fontSize
  frame .tOption.fYlabel
  label .tOption.fYlabel.l -text Ylabel
  entry .tOption.fYlabel.e -textvariable ylabel
  frame .tOption.fRatio
  label .tOption.fRatio.l -text Ratio
  entry .tOption.fRatio.e -textvariable ratio
  frame .tOption.fYtics
  label .tOption.fYtics.l -text Ytics
  entry .tOption.fYtics.e -textvariable ytics
  button .tOption.bCommon -text Common -command {
    toplevel .tOption.tCommon
    wm title .tOption.tCommon Common
    grab set .tOption.tCommon
    button .tOption.tCommon.bClose -text Close -command {
      destroy .tOption.tCommon
      grab set .tOption
    }
    frame .tOption.tCommon.fPath
    label .tOption.tCommon.fPath.l -text "Working Directory"
    entry .tOption.tCommon.fPath.e -textvariable WD -width 100
    button .tOption.tCommon.fPath.b -text Select -command {
      set tmp [tk_chooseDirectory -initialdir $WD -title "Select a working directory" -parent .tOption.tCommon]
      if {$tmp ne ""} {
	set WD $tmp
      }
    }
    pack .tOption.tCommon.fPath .tOption.tCommon.bClose
    pack .tOption.tCommon.fPath.l .tOption.tCommon.fPath.e .tOption.tCommon.fPath.b -side left
  }
  button .tOption.bbandgnu -text bandgnu -command {
    toplevel .tOption.tbandgnu
    wm title .tOption.tbandgnu bandgnu
    grab set .tOption.tbandgnu
    button .tOption.tbandgnu.bClose -text Close -command {
      destroy .tOption.tbandgnu
      grab set .tOption
    }
    frame .tOption.tbandgnu.fMode
    label .tOption.tbandgnu.fMode.l -text "Processing Method"
    radiobutton .tOption.tbandgnu.fMode.rbTcl -text "Internal" -variable bandgnuMode -value Tcl
    radiobutton .tOption.tbandgnu.fMode.rbC -text "External (requires 'bandgnu*.c')" -variable bandgnuMode -value C
    frame .tOption.tbandgnu.fPath
    label .tOption.tbandgnu.fPath.l -text "Path of 'bandgnu'"
    entry .tOption.tbandgnu.fPath.e -textvariable bandgnuPath -width 100
    button .tOption.tbandgnu.fPath.b -text Select -command {
      set tmp [tk_getOpenFile -initialdir $dir -filetypes {{{source file} {bandgnu*.c}}} -title "Select a source file of 'bandgnu'" -parent .tOption.tbandgnu]
      if {$tmp ne ""} {
	set bandgnuPath $tmp
      }
    }
    frame .tOption.tbandgnu.fAP
    label .tOption.tbandgnu.fAP.l -text "Automatic Export"
    radiobutton .tOption.tbandgnu.fAP.rbOn -text On -variable bandgnuAE -value on
    radiobutton .tOption.tbandgnu.fAP.rbOff -text Off -variable bandgnuAE -value off
    frame .tOption.tbandgnu.fColor
    label .tOption.tbandgnu.fColor.l -text "Background Color"
    entry .tOption.tbandgnu.fColor.e -textvariable bandgnuColor -width 10
    button .tOption.tbandgnu.fColor.b -text Select -command {
      set tmp [tk_chooseColor -initialcolor $bandgnuColor -parent .tOption.tbandgnu]
      if {$tmp ne ""} {
	set bandgnuColor $tmp
      }
    }
    frame .tOption.tbandgnu.fPreview
    label .tOption.tbandgnu.fPreview.l -text "Preview (for 'Internal Processing')"
    radiobutton .tOption.tbandgnu.fPreview.rbOn -text On -variable bandgnuPreview -value on
    radiobutton .tOption.tbandgnu.fPreview.rbOff -text Off -variable bandgnuPreview -value off
    frame .tOption.tbandgnu.fExport
    label .tOption.tbandgnu.fExport.l -text "Export Format"
    entry .tOption.tbandgnu.fExport.e -textvariable bandgnuExport -width 15
    button .tOption.tbandgnu.fExport.b -text Select -command {
      toplevel .tOption.tbandgnu.tExport
      wm title .tOption.tbandgnu.tExport Export
      grab set .tOption.tbandgnu.tExport
      labelframe .tOption.tbandgnu.tExport.lfExport -text "Export Format"
      listbox .tOption.tbandgnu.tExport.lfExport.lb
      .tOption.tbandgnu.tExport.lfExport.lb insert end "postscript eps" pdf png jpeg svg emf gif
      button .tOption.tbandgnu.tExport.bClose -text Close -command {
	set bandgnuExport [.tOption.tbandgnu.tExport.lfExport.lb get [.tOption.tbandgnu.tExport.lfExport.lb curselection]]
	destroy .tOption.tbandgnu.tExport
	grab set .tOption.tbandgnu
      }
      pack .tOption.tbandgnu.tExport.lfExport .tOption.tbandgnu.tExport.bClose
      pack .tOption.tbandgnu.tExport.lfExport.lb
    }
    frame .tOption.tbandgnu.fEnhanced
    label .tOption.tbandgnu.fEnhanced.l -text "Enhanced Expression"
    radiobutton .tOption.tbandgnu.fEnhanced.rbOn -text On -variable bandgnuEnhanced -value on
    radiobutton .tOption.tbandgnu.fEnhanced.rbOff -text Off -variable bandgnuEnhanced -value off
    pack .tOption.tbandgnu.fMode .tOption.tbandgnu.fPath .tOption.tbandgnu.fAP .tOption.tbandgnu.fColor .tOption.tbandgnu.fPreview .tOption.tbandgnu.fExport .tOption.tbandgnu.fEnhanced .tOption.tbandgnu.bClose
    pack .tOption.tbandgnu.fMode.l .tOption.tbandgnu.fMode.rbTcl .tOption.tbandgnu.fMode.rbC -side left
    pack .tOption.tbandgnu.fPath.l .tOption.tbandgnu.fPath.e .tOption.tbandgnu.fPath.b -side left
    pack .tOption.tbandgnu.fAP.l .tOption.tbandgnu.fAP.rbOn .tOption.tbandgnu.fAP.rbOff -side left
    pack .tOption.tbandgnu.fColor.l .tOption.tbandgnu.fColor.e .tOption.tbandgnu.fColor.b -side left
    pack .tOption.tbandgnu.fPreview.l .tOption.tbandgnu.fPreview.rbOn .tOption.tbandgnu.fPreview.rbOff -side left
    pack .tOption.tbandgnu.fExport.l .tOption.tbandgnu.fExport.e .tOption.tbandgnu.fExport.b -side left
    pack .tOption.tbandgnu.fEnhanced.l .tOption.tbandgnu.fEnhanced.rbOn .tOption.tbandgnu.fEnhanced.rbOff -side left
  }
  button .tOption.bReset -text Reset -command {
    file delete $rootPath/.omxtoolrc
    set yraMax 3
    set yraMin -3
    set fontSize 36
    set bandgnuPath ""
    set bandgnuMode Tcl
    set WD $rootPath
    set bandgnuAE on
    set ylabel "Energy (eV)"
    set bandgnuColor #000000
    set bandgnuPreview on
    set bandgnuExport "postscript eps"
    set bandgnuEnhanced on
    set ratio 1
    set ytics 1
  }
  button .tOption.bClose -text Close -command {
    destroy .tOption
    saveSetting
  }
  pack .tOption.fYra .tOption.fYtics .tOption.fFontSize .tOption.fYlabel .tOption.fRatio .tOption.bReset .tOption.bCommon .tOption.bbandgnu .tOption.bClose
  pack .tOption.fYra.l .tOption.fYra.ll .tOption.fYra.eMin .tOption.fYra.lc .tOption.fYra.eMax .tOption.fYra.lr -side left
  pack .tOption.fFontSize.l .tOption.fFontSize.e -side left
  pack .tOption.fYlabel.l .tOption.fYlabel.e -side left
  pack .tOption.fRatio.l .tOption.fRatio.e -side left
  pack .tOption.fYtics.l .tOption.fYtics.e -side left
}
set openmx_tcl [file normalize $argv0]
set rootPath [file dirname $openmx_tcl]
set nwin 0
set gp ""
set yraMax 3
set yraMin -3
set fontSize 36
set bandgnuPath ""
set bandgnuMode Tcl
set ylabel "Energy (eV)"
set WD $rootPath
set bandgnuAE on
set bandgnuColor #000000
set bandgnuPreview on
set bandgnuExport "postscript eps"
set bandgnuEnhanced on
if [file exists $rootPath/.omxtoolrc] {
  source $rootPath/.omxtoolrc
} else {
  saveSetting
}
set dir $WD
wm protocol . WM_DELETE_WINDOW {exit}
if {[info exists env(HOSTNAME)]} {
  set HOSTNAME $env(HOSTNAME)
} else {
  set HOSTNAME localhost
}
wm title . "OMXTool.tcl@$HOSTNAME"
label .l0 -textvariable buff
label .l1 -textvariable buff1 -justify left
button .bband -text Band -command band
button .bOption -text Option -command openOption
button .bexit -text Exit -command exit
pack .l0 .l1 .bband .bOption .bexit -expand 1 -fill both
while 1 {
  set buff [status]
  set buff1 [status1]
  .l0 configure -textvariable buff
  .l1 configure -textvariable buff1
  update
  after 100
}
