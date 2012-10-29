[% INCLUDE header.tpl %]
 <div class="post">
  [% IF meta.project_title %]
   <div class="meta">
    <pre>Project: <a href="/blarg/[% meta.project_url %]">[% meta.project_title %]</a></pre>
   </div>
  [% END %]
  [% content %]
 </div>
[% INCLUDE footer.tpl %]
