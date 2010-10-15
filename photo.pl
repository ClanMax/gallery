#!/usr/bin/perl -w
use DBI;
use Image::Resize;
opendir(PHOTODIR,Photo) or die "Не удалось открыть каталог $!";
#$i=0;
my $dsn = 'DBI:mysql:gallery:localhost';
my $db_user_name = 'root'; # login your database
my $db_password = 'passwords'; #password your database 
my ($id, $password);
$db = DBI->connect($dsn, $db_user_name, $db_password) or die "Не удалось подключиться к базе 
данных";
foreach ( grep { /\.jpg$/ } readdir(PHOTODIR) ) {
      $_ =~ s/(.*)\.jpg/$1/g;
      $photo = $_;
      $search = $db->do("SELECT * FROM `photo` WHERE `name` = '$photo'");
      if ($search < 1) {
         $add = $db->do("INSERT INTO `gallery`.`photo` (`name`, `tag`, `date`) VALUES ('$photo', 
NULL, NOW());");
	 prew();
         if ($add=>1) {
            print "$photo удачно добавлена в базу данных \n"
         }
         else {
            print "Не удалось добавить $photo в базу данных \n"
      }
    }
  }
sub prew {
    $prew = Image::Resize->new("Photo/$photo.jpg");
    $gd = $prew->resize(135, 129);
    open(PREW, ">/home/vladan/prew/prew$photo.png");
        print PREW $gd->png();
        close PREW;
  }
     
