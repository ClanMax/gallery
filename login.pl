#!/usr/bin/perl -w
use DBI; 
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use CGI::Cookie;
use Digest::MD5 qw(md5_hex);

my $dsn = 'DBI:mysql:gallery:localhost';
my $db_user_name = 'root'; # login your database
my $db_password = 'passwords'; # passwords your database
$db = DBI->connect($dsn, $db_user_name, $db_password) or die "Не удалось подключиться к базе";

print "Content-Type: text/html\n\n";
# Проверим вошел ли юзер или нет
$cgi = new CGI;
$login = $cgi->param('login');
$passwords = $cgi->param('passwords');
if ($login && $passwords > 0 ) {
	$passwords = md5_hex($passwords);
	$auth = $db->do("SELECT * FROM `users` WHERE `name` = '$login' AND `password` = '$passwords'");
	if ($auth > 0) {
		my $session;
		my @rnd_txt = ('0','1','2','3','4','5','6','7','8','9',
       		               'A','a','B','b','C','c','D','d','E','e',
			       'F','f','G','g','H','h','I','i','J','j',
			       'K','k','L','l','M','m','N','n','O','o',
			       'P','p','R','r','S','s','T','t','U','u',
			       'V','v','W','w','X','x','Y','y','Z','z');
 		srand;
		for (0..31) {
			my $s = rand(@rnd_txt);
			$session .= $rnd_txt[$s]
			}
		$db->do("UPDATE  `gallery`.`users` SET  `session` =  '$session' WHERE  `users`.`name` = 
'$login'");
		print '<SCRIPT LANGUAGE="JavaScript">this.document.cookie="session='.$session.
		        ';path=/;domain=.clanmax.ru;expires=Sunday,31-Dec-19 23:59:59 GMT;";</SCRIPT>
			<SCRIPT LANGUAGE="JavaScript">this.document.cookie="login='.$login.
			';path=/;domain=clanmax.ru;expires=Sunday,31-Dec-19 23:59:59 GMT;";</SCRIPT>';
		print "Location: index.pl \n\n";
        	}
	}

# Работа с cookies 
my %cookies = fetch CGI::Cookie;
if ($cookies{'session'} && $cookies{'login'}) {
	$cookies{'session'} = $cookies{'session'}->value;
	$cookies{'login'} = $cookies{'login'}->value;
	$cookiesdb = $db->prepare("SELECT name FROM `users` WHERE `session` = '.$cookies{'session'}.'");
		$cookiesdb->execute(); 
		$cookiesdb->fetchrow_hashref();
		$cookiesdb->finish();
	if ($cookiesdb > 0) {
		if ($cookiesdb eq $cookies{'login'}) {
			print "Location: index.pl \n\n";
			}
		else {
	        login();
		}
	}
}
else {
	login();
}

sub login {
print "
<html>
<body>
<title>Галерея: вход</title>
<form name = 'if' method = 'post' action = 'login.pl'>
<input name = 'login' type = 'text'>
<br><input name = 'passwords' type = 'password'>
<br><input type = 'submit' value = 'Отправить'>
";
}

