<!-- auth#password view template of myapp
          Please add your license header here.
          This file is generated automatically by GNU Artanis. -->
<HTML>
	<HEAD>
		<TITLE>
			<%= (current-appname) %>
		</TITLE>

		<@css dashboard.css %>
		<@css  profiles.css %>

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
			<HEADER class="profile_header">
				<% (let ([images (ap-actor-images actor)])
				     (unless (null? images) %>
				       <IMG id="landscape"
				            src=<%= (uri->string (ap-image-url (car images))) %>>
				  <% )) %>

				<% (let ([icons (ap-actor-icons actor)])
				     (unless (null? icons) %>
				       <IMG id="icon"
				            src=<%= (uri->string (ap-image-url (car icons))) %>>
				  <% )) %>
			</HEADER>

			<SECTION class="profile_body">
				<H1>
						<B>
							<%= (ap-actor-name actor) %>
						</B>
					<BR />
						<SMALL>
							@<%= (ap-actor-preferred-username actor) %>@<%= (uri-host (ap-actor-ap-id actor)) %>
						</SMALL>
				</H1>

				<% (unless (string-null? (ap-actor-summary actor)) %>
				     <%= (ap-actor-summary actor) %>
				<% ) %>
			</SECTION>
		</DIV>
	</BODY>
</HTML>
