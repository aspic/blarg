<!DOCTYPE html>
<html>
 <head>
  <meta charset="UTF-8">
  <title>[% meta.title %]</title>
  <link rel="stylesheet" type="text/css" href="/blarg/css/style.css">
 </head>
 <body>
  <div class="site">
   <h1 style="display: inline;">mehl.no</h1>
   <nav>
    <ul>
     <li><a href="/blarg/index.html">Home</a></li>
     <li><a href="/blarg/about.html">About</a></li>
     [% IF meta.tag %]
      <li><a href="/blarg/[% meta.tag %].html">Tags</a></li>
     [% END %]
    </ul>
   </nav>
