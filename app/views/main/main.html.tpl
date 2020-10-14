<!-- auth#password view template of myapp
          Please add your license header here.
          This file is generated automatically by GNU Artanis. -->
<HTML>
	<HEAD>
		<TITLE>
			<%= (current-appname) %>
		</TITLE>

		<@css   dashboard.css %>
		<@css       posts.css %>
		<@css post-editor.css %>

		<SCRIPT type="text/javascript">
			/*
			 * @licstart  The following is the entire license notice for the
			 * JavaScript code in this page.
			 *
			 * Copyright (C) 2014  Loic J. Duros
			 *
			 * The JavaScript code in this page is free software: you can
			 * redistribute it and/or modify it under the terms of the GNU
			 * General Public License (GNU GPL) as published by the Free Software
			 * Foundation, either version 3 of the License, or (at your option)
			 * any later version.  The code is distributed WITHOUT ANY WARRANTY;
			 * without even the implied warranty of MERCHANTABILITY or FITNESS
			 * FOR A PARTICULAR PURPOSE.  See the GNU GPL for more details.
			 *
			 * As additional permission under GNU GPL version 3 section 7, you
			 * may distribute non-source (e.g., minimized or compacted) forms of
			 * that code without the copy of the GNU GPL normally required by
			 * section 4, provided you include this license notice and a URL
			 * through which recipients can access the Corresponding Source.
			 *
			 *
			 * @licend  The above is the entire license notice
			 * for the JavaScript code in this page.
			 */
		</SCRIPT>
	</HEAD>

	<BODY>
		<@include dashboard.html %>

		<DIV class="dash_main">
			<% (for-each
			     (lambda (post)
			       (let* ([creator               (car (ap-post-attributed-to post))]
			              [editorID        (string-append/shared
			                                 "editor_"
			                                 (number->string (ap-post-db-id post)))]
			              [fullCreatorName (string-append/shared
			                                 (ap-actor-preferred-username creator)
			                                 "@"
			                                 (uri-host (ap-actor-ap-id creator))
			                                 "&#10;"
			                                 "&#10;")]) %>
				<DIV class="dash_post">
					<HEADER class="dash_post-info">
						<% (when (not (null? (ap-actor-icons creator))) %>
							<IMG id="icon"
							     src=<%= (uri->string (ap-image-url (car (ap-actor-icons creator)))) %>>
						<% ) %>

						<DIV id="post-info">
							<DIV id="poster">
								<B>
									<%= (ap-actor-name creator) %>
								</B>

								<SPAN style="color: #888888">
									&nbsp;&nbsp;<%= fullCreatorName %>
								</SPAN>
							</DIV>

							<DIV id="timestamp">
								<I>
									<%= (if-let ([publishDate (ap-post-published post)])
									        (string-append
									          (date->string publishDate "~a: ~B ~d, ~Y &ndash; ")
									          "<u>"
									          (date->string publishDate "~l:~M:~S ~p")
									          "</u>")
									      "") %>
								</I>
							</DIV>
						</DIV>
					</HEADER>

					<ARTICLE class="dash_post-content" data-users=<%= fullCreatorName %>>
						<%= (ap-post-content post) %>
					</ARTICLE>

					<@include post-editor.html %>

					<FOOTER class="dash_post-interactions"
					        data-inbox=<%= (uri->string (ap-actor-inbox creator)) %>
					        data-activity-pub-id=<%= (uri->string (ap-post-ap-id post)) %>>
						<@include chat-button.html %>

						<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1.3em" height="1.3em" preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24" class="iconify icon:gridicons-reblog" data-inline="false" data-width="1.3em" data-height="1.3em" data-icon="gridicons-reblog" style="transform: rotate(360deg);" id="reblog"><path d="M22.086 9.914L20 7.828V18a2 2 0 0 1-2 2h-7v-2h7V7.828l-2.086 2.086L14.5 8.5L19 4l4.5 4.5l-1.414 1.414zM6 16.172V6h7V4H6a2 2 0 0 0-2 2v10.172l-2.086-2.086L.5 15.5L5 20l4.5-4.5l-1.414-1.414L6 16.172z" fill="#707B97"></path><rect height="4" y="10" ry="2" fill-opacity="null" stroke-width="null" id="svg_9" width="4" x="10" rx="2" stroke-opacity="null" stroke="null" /></svg>

						<SVG xmlns="http://www.w3.org/2000/svg"
						     xmlns:xlink="http://www.w3.org/1999/xlink"
						     aria-hidden="true"
						     focusable="false"
						     width="1.3em"
						     height="1.3em"
						     preserveAspectRatio="xMidYMid meet"
						     viewBox="0 0 24 24"
						     class="iconify icon:gridicons-reblog"
						     data-inline="false"
						     data-width="1.3em"
						     data-height="1.3em"
						     data-icon="gridicons-reblog"
						     style="transform: rotate(360deg);">
							<PATH d="M22.086 9.914L20 7.828V18a2 2 0 0 1-2 2h-7v-2h7V7.828l-2.086 2.086L14.5 8.5L19 4l4.5 4.5l-1.414 1.414zM6 16.172V6h7V4H6a2 2 0 0 0-2 2v10.172l-2.086-2.086L.5 15.5L5 20l4.5-4.5l-1.414-1.414L6 16.172z"
							      fill="#117EB0">
							</PATH>

							<RECT height="4" y="10" ry="2"   fill-opacity="null" stroke-width="null" id="svg_9"
							       width="4" x="10" rx="2" stroke-opacity="null" stroke="null"       fill="#117EB0" />
						</SVG>
						<!-- #1595D1 -->

						<% (when (not (member user (ap-post-users-who-have-liked post))) %>
						     <@include like-button_unclicked.html %>
						<% ) %>
						<% (when (member user (ap-post-users-who-have-liked post)) %>
						     <@include like-button_clicked.html %>
						<% ) %>
					</FOOTER>
				</DIV>
			<% )) posts) %>
		</DIV>
	</BODY>
</HTML>
