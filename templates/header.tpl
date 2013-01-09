<!DOCTYPE html>
<html>
 <head>
  <meta charset="UTF-8">
  <title>[% meta.title %]</title>
  <link rel="stylesheet" type="text/css" href="/blarg/css/style.css">
  <link rel="icon" type="image/x-icon" href="/blarg/img/favicon.ico" />
 </head>
 <body>
  <div class="site">
   <h1 style="display: inline;">mehl.no</h1>
   <nav>
    <ul>
     <li><a href="/blarg/index.html">Home</a></li>
     <li><a href="/blarg/about.html">About</a></li>
     [% IF meta.tag %]
      <li><a href="/blarg/[% meta.tag %]">Tags</a></li>
     [% END %]
    </ul>
   </nav>
