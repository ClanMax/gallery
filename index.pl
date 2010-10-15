#!/usr/bin/perl -w
use DBI; 
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use CGI::Cookie;

my $dsn = 'DBI:mysql:gallery:localhost';
my $db_user_name = 'root'; # login your database
my $db_password = 'password'; # passwords your database
my ($id, $password);
$db = DBI->connect($dsn, $db_user_name, $db_password) or die "Не удалось подключиться к базе";


# Работа с cookies 
my %cookies = fetch CGI::Cookie;
if ($cookies{'session'}) {
	$cookies{'session'}  = $cookies{'session'}->value;
	$cookies{'login'} = $cookies{'login'}->value;
	$cookiesdb = $db->prepare("SELECT name FROM `users` WHERE `session` = '.$cookie{'session'}.'");
		$cookiesdb->execute(); 
		$cookiesdb->fetchrow_array;

#	if ($cookiesdb eq $$cookies{'login'}  ) {
			gallery();
#	}
#	else {
#		print "Location: login.pl \n\n";
#		exit;
#		}
}
else {
	print "Location: login.pl\n\n";
	exit;
	}

sub gallery {
print "Content-Type: text/html\n\n";
print "<html>
<body>
<title>В разработке же</title>

";
my ($name, $i);
$photo=$db->prepare('select name from photo order by date desc');
$photo->execute;
$photo->bind_columns(\($name));
while ($photo->fetch) {
	if ($i<3) {
	    print "<a href='photo/$name.jpg'><img src='prew/prew$name.png'></a>";
            $i++;
	}
	else {
 	    print "<a href='photo/$name.jpg'><img src=\"prew/prew$name.png\"></a><br>";
	    $i=0;
        }
    }  	
} 
