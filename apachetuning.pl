#!/usr/bin/perl
#Author: Rajiv C.J.
#Contact: rajivcj12@gmail.com
#Distributed under GPL v3

my $pwd = `pwd`;
if ( $ARGV[0] eq "-c" )
{
 apachecalculate();
}
elsif ( $ARGV[0] eq "-o" )
{
 optimize();
}
elsif ( $ARGV[0] eq "-r" )
{
 cronremove();
}
else {

  if ( -e "/apachetunig/cron.lock")
  {
        print "Cron is already set. Use -r switch to remove it\n";
        exit;
  }


if ( -d "/apachetunig" ) 
 {
  
 if ( -e "/apachetunig/result.txt")
  {
    print " File apachetuningresult.txt already exist, do you want to remove it ?";
    my $opt=<>;
    chomp $opt;
    if ($opt =~ /(y|Y)/)
      {
        `rm -rf /apachetunig/result.txt`;
      }
    else 
      {
        exit;
      }
 } 
 }
else 
{ 
 `mkdir /apachetunig`;  
 `touch /apachetunig/result.txt`;
}
  setcron();
 }


sub apachecalculate
{
my $avg = `ps -ylC httpd | awk '{x += \$8;y += 1 } END {print x/((y-1)*1024)}'`;
open (DATA,'>>',"/apachetunig/result.txt") || die "Error opening result  file";
print DATA "$avg";
close DATA;
}

sub setcron
{
my $pwd = `pwd`;
chomp($pwd);
my $time=`date '+\%s'`;
chomp ($time);
my $twentythreeh = $time + 82800;
my $twentyfour = $time + 86400;
my $cron1 = localtime($time);
my $cron2 = localtime($twentythreeh);
my $cron3 = localtime($twentyfour);
my @ttime = split /[\s,:]/, $cron2;
my $cr2 = $ttime[3];
@ttime = split /[\s,:]/, $cron3;
my $cr3 = $ttime[3];

if ( -e "/var/spool/cron/root")
  {
   `cp -rp /var/spool/cron/root /var/spool/cron/root-preedit`;
   }
else 
  {
   `touch /var/spool/cron/root`;
  }
    
open (CRON,'>>',"/var/spool/cron/root") || die "Error opening roots cron file";
 print CRON "*/10 * * * * perl $pwd/apachetuning-new.pl -c\n";
 print CRON "00 $cr3 * * * perl $pwd/apachetuning-new.pl -o\n";
 print CRON "05 $cr3 * * * perl $pwd/apachetuning-new.pl -r\n";    
`touch /apachetunig/cron.lock`;
}

sub cronremove

{
if (-e "/var/spool/cron/root-preedit")
 {
 `cp -rp /var/spool/cron/root-preedit /var/spool/cron/root`;
 }
else 

 {
 `rm -rf /var/spool/cron/root`;
 }
`rm -rf /apachetunig/cron.lock`;
}
sub optimize
{
 open (DATA2,"/apachetunig/result.txt") || die "Error opening kayako file";
 my @result = <DATA2>;
 my $numberofvalues = $#result;
$numberofvalues = $numberofvalues + 1;
 my $sum;
 foreach ( @result )
 {
  $sum += $_;
 }
 my $avg = $sum/$numberofvalues;
 
 
 my $totalmemory = `free -m | grep Mem | awk '{print \$2}'`;
 
my $MaxClients = ( $totalmemory - 512) /$avg ;
`touch /apachetunig/maxclient.txt`;
my $date = `date '+\%F'`;
my $time= `date '+\%T'`;
chomp($time);
chomp($date);
open (MAXCLI,'>',"/apachetunig/maxclient.txt") || die "Error opening roots maxclient file";
print MAXCLI "Created on :$date--$time\nTotal memory = $totalmemory Average memory used by apache = $avg\nMAXCLIENTS THAT HAS TO BE SET == $MaxClients\n";
}
