proc analyze_callback { name1 name2 op } {
  global analyze_proc

  upvar $name1 arr
  set frame $arr($name2)
  uplevel #0 $analyze_proc $frame
}

proc analyze { script } {
  global analyze_proc
  #puts "hha"
  set analyze_proc $script
  uplevel #0 trace variable vmd_frame w analyze_callback
}


## code for analysis starts from here#

set inputpsf "noname.psf"
set inputdcd "noname.dcd"
set sresids 0
set sreside 1
source tempinput.tcl
set rofgyr {}
set mingyr {}
set maxgyr {}
set totres [expr $sreside-$sresids+1]
puts " $totres residues will be taken into consideration..."
proc my_analysis { frame } {
  #global inputpsf 
  #global inputdcd
  puts " analyzing the ${frame}-th frame ... " 
  global sresids 
  global sreside
  global rofgyr
  global mingyr
  global maxgyr
  global totres
  set gyrtot 0.0
  set gyrmin 0.0
  set gyrmax 0.0
  for { set i $sresids } { $i <= $sreside } { incr i } {
    #puts " $i $sreside"
    set sel [atomselect top "resid $i"]
    set tempgry [measure rgyr $sel]
    set gyrtot [expr $gyrtot+$tempgry]
    #puts " $gyrtot"
    if { $i == $sresids } {
      set gyrmin $tempgry
      set gyrmax $tempgry
    } else {
      if { $gyrmin > $tempgry } {
        set gyrmin $tempgry
      }
      if { $gyrmax < $tempgry } {
        set gyrmax $tempgry
      }
    }
    #puts " $gyrmin"
    #puts " $gyrmax"
    $sel delete
    #puts " next"
  }

  lappend rofgyr [expr $gyrtot/$totres]
  lappend mingyr $gyrmin
  lappend maxgyr $gyrmax
}


#cd /home/justin/vmd/vmd/proteins

analyze my_analysis

mol load psf ${inputpsf} dcd ${inputdcd}

set outputfile "rogyr.dat"
set outfp [open $outputfile w]
set tnum 1
foreach i $rofgyr j $mingyr k $maxgyr {
  #puts $outfp [format "%d\t%.4f\t%.4f\t%.4f" $tnum $i [expr ($j-$i)/$i] [expr ($k-$i)/$i]]
  puts $outfp [format "%d\t%.4f\t%.4f\t%.4f" $tnum $i $j $k]
  incr tnum
}



quit


# analysis ends here #