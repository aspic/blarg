[% INCLUDE header.tpl %]
 <div class="post">
  [% IF meta.project %]
   <div class="meta">
    <pre>Project: <a href="/blarg/[% meta.project %]">[% meta.project %]</a></pre>
   </div>
  [% END %]
  [% content %]
 </div>
[% INCLUDE footer.tpl %]
