#!/usr/bin/env perl

use Mojolicious::Lite;
use Digest::MD5 qw(md5_hex);
use DBI;
use utf8;

my $dsn = 'DBI:mysql:gallery:localhost';
my $db_user_name = 'root'; # Логин базы данных | Login your database 
my $db_password = 'password'; # Пароль от базы данных | Password your database 
my $db = DBI->connect($dsn, $db_user_name, $db_password) || "Не удалось подключиться к базе";


get '/login' => sub {
        my $self = shift;

	# Получаем параметры из get запроса и проверяем их на валидность. 

        my $name = $self->param('name') || '';
        my $pass = $self->param('pass') || '';

	##################
	# Нужно сделать проверку по паролю в md5. Хранить в открытом виде не очень хочется. 
	##################

	my $check = $db->do("SELECT * FROM `users` WHERE `name` = '$name' AND `password` =
	'$pass'");
        return $self->render unless $check != 0;
	$self->session(name => $name);
        $self->flash(message => 'Thanks for logging in!');
        $self->redirect_to('index');
    } => 'login';

get '/' => sub {
        my $self = shift;
        return $self->redirect_to('login') unless $self->session('name');
	my ($photo);

	# Выводим фото | Check and show photo of database
	$photo=$db->prepare('select name from photo order by date desc'); 
	$photo->execute;
	$self->render(photo => $photo); #Отсылаем параметр $photo в шаблон 
    } => 'index';

get '/logout' => sub {
        my $self = shift;
        $self->session(expires => 1);
        $self->redirect_to('index');
    } => 'logout';
    
app->start;
__DATA__

@@ layouts/default.html.ep
<!doctype html><html>
<head><title>Галерея</title></head>
<body><%= content %></body>
</html>

@@ login.html.ep
% layout 'default';
    <%= form_for login => {%>
        <% if (param 'name') { %>
            <b>Wrong name or password, please try again.</b><br />
        <% } %>
        Name:<br />
        <%= input name => (type => 'text') %><br />
        Password:<br />
        <%= input pass => (type => 'text') %><br />
        <input type="submit" value="Login" />
    <%}%>

@@ index.html.ep
% layout 'default';
    <% if (my $message = flash 'message' ) { %>
        <b><%= $message %></b><br />
    <% } %>
    Welcome <%= session 'name' %>!
    <%= link_to logout => {%>
        Logout<br>
    <%}%>
    <% my $name; %>
    <% $photo -> bind_columns(\$name); %>
    <% while ($photo->fetch) { %>
        <a href='photo/<%= $name %>.jpg'><img src='prew/prew<%= $name %>.png'></a><br>
    <% } %>
