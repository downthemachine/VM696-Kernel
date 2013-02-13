#!/usr/bin/perl -W
use strict;
use Cwd;

my $dir = getcwd;
print "\nVM696\n";
print "\ncleaning kernel source\n";


print "\nremoving old boot.img\n";
system ("rm boot.img");
system ("rm $dir/zpack/zcwmfiles/boot.img");

print "\nremoving old vm696_krnl.zip\n";
system ("rm $dir/vm696_krnl.zip");

print "\ncreating ramdisk from vm696 folder\n";
chdir ("$dir/zpack");

 unless (-d "$dir/zpack/vm696/data") {
 system ("mkdir vm696 | tar -C /$dir/zpack/vm696/ -xvf vm696.tar");
 }

chdir ("$dir/zpack/vm696");
system ("find . | cpio -o -H newc | gzip > $dir/ramdisk-repack.gz");


print "\nbuilding zImage from source\n";
chdir ("$dir");
system ("cp defconfig $dir/.config");
system ("make -j8");

print "\ncreating boot.img\n";
chdir $dir or die "/zpack/vm696 $!";;
system ("$dir/zpack/mkbootimg --cmdline 'console=ttyMSM1,115200' --kernel $dir/arch/arm/boot/zImage --ramdisk ramdisk-repack.gz -o boot.img --base 0x00200000 --pagesize 4096");

unlink("ramdisk-repack.gz") or die $!;

print "\ncreating flashable zip file\n";
system ("cp boot.img $dir/zpack/zcwmfiles/");
chdir ("$dir/zpack/zcwmfiles");
system ("zip -9 -r $dir/vm696_krnl.zip *");
print "\nceated vm696_krnl.zip\n";

print "\nremoving old vm696_krnl.zip from sdcard\n";
system ("adb shell rm /sdcard/vm696_krnl.zip");

print "\npushing vm696_krnl.zip to sdcard\n";
system ("adb push $dir/vm696_krnl.zip /sdcard");
print "\ndone\n";

