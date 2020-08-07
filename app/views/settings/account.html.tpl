<!-- auth#password view template of myapp
          Please add your license header here.
          This file is generated automatically by GNU Artanis. -->
<HTML>
	<HEAD>
		<TITLE>
			<%= (current-appname) %>
		</TITLE>

		<@css dashboard.css %>
		<@css   account.css %>

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
			<DIV class="dash_account">
				<H1>
					Account Settings
				</H1>

				<DIV class="account_details">
					<DIV class="details_row">
						<DIV class="details_left">
							Username
						</DIV>

						<DIV class="details_right">
							temp_boiler
						</DIV>
					</DIV>

					<DIV class="details_row">
						<DIV class="details_left">
							E-mail
						</DIV>

						<DIV class="details_right">
							temp_boiler@fake.com
						</DIV>
					</DIV>

					<DIV class="details_row">
						<DIV class="details_left">
							Display Name
						</DIV>

						<DIV class="details_right">
							<INPUT type="text" name="display_name">
						</DIV>
					</DIV>

					<DIV class="details_row">
						<DIV class="details_left">
							Bio.
						</DIV>

						<DIV class="details_right">
							<TEXTAREA type="text" name="display_name">
							</TEXTAREA>
						</DIV>
					</DIV>
				</DIV>
			</DIV>
		</DIV>
	</BODY>
</HTML>
