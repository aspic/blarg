[% INCLUDE header.tpl %]
 <div class="post">
  [% IF meta.project_title %]
   <div class="meta">
<pre>[% IF meta.project_title %]Project: <a href="/blarg/[% meta.project_url %]">[% meta.project_title %]</a>[% END %]
[% IF meta.tags && meta.tags.size > 0 %]Tag(s): [% FOREACH tag = meta.tags %][% tag %] [% END %][% END %]</pre>
   </div>
  [% END %]
  [% content %]
 </div>
[% INCLUDE footer.tpl %]
