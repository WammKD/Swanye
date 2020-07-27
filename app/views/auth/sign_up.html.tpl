<!-- auth#sign_up view template of myapp
          Please add your license header here.
          This file is generated automatically by GNU Artanis. -->
<HTML>
	<HEAD>
		<TITLE>
			<%= (current-appname) %>
		</TITLE>

		<@css forms.css %>

		<SCRIPT>
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
		<DIV class="form_container">
			<H1 align="center">
				Swanye
			</H1>

			<!-- Need to set this up so it handles if the username already exists -->
			<FORM class="basic_form" action="/auth/sign_up" method="post">
					E-mail:
				<BR />
					<INPUT  type="text"     name="email">
				<BR />
					Username:
				<BR />
					<INPUT  type="text"     name="username">
				<BR />
					Password:
				<BR />
					<INPUT  type="password" name="password">
				<BR />
				<BR />
					<BUTTON type="submit"   name="button">
						Sign Up!
					</BUTTON>
			</FORM>
		</DIV>
	</BODY>
</HTML>
