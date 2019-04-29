<!-- auth#password view template of myapp
          Please add your license header here.
          This file is generated automatically by GNU Artanis. -->
<HTML>
	<HEAD>
		<TITLE>
			<%= (current-appname) %>
		</TITLE>

		<@css dashboard.css %>

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
			var ACCEPT = 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"';

			function handleSearch(el) {
				if(event.key === "Enter") {
					var v = el.value[0] === "@" ? el.value
					                                .substring(1)
					                                .split("@")   : el.value
					                                                  .split("@");

					if(v.length === 2) {
						var call = new XMLHttpRequest();

						call.open("GET", "https://"                              + v[1] +
														 "/.well-known/webfinger?resource=acct:" + v[0] +
														 "%40"                                   + v[1]);
						call.onreadystatechange = function() {
						                          	if(this.readyState == 4   &&
						                          	   this.status     == 200) {
						                          		var links = JSON.parse(call.responseText).links,
						                          		    link,
						                          		    url   = "";

						                          		for(linkIndex in links) {
						                          			var link = links[linkIndex];

						                          			if(link.type === "application/activity+json") {
						                          				url = link.href;
						                          			}
						                          		}

						                          		document.getElementById("search_results")
						                          		        .innerHTML = "<DIV class='search_result'>"                   +
						                          		                       url.substring(url.lastIndexOf("/users/") + 7) +

						                          		                       "<DIV class='follow_icon'></DIV>"             +
						                          		                     "</DIV>";
						                          	}
						                          };
						call.send();
					} else {
						alert("fuck");
					}
				}
			}
		</SCRIPT>
	</HEAD>

	<BODY>
		<DIV class="dash_side">
			<DIV class="dash_button">
				<P style="font-size: 9.15vh; margin-block-start: -.1em; margin-block-end: -.15em;">
					Aa
				</P>

				<DIV>
					Text
				</DIV>
			</DIV>

			<DIV class="dash_button">
				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20viewBox='0%200%2030%2030'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23fff'%20d='M7%205H6a1%201%200%200%200-1%201h3a1%201%200%200%200-1-1z'/%3E%3Ccircle%20fill='%23fff'%20cx='15'%20cy='15'%20r='5'/%3E%3Cpath%20fill='%23fff'%20d='M26%207h-4.264a2%202%200%200%201-1.789-1.106l-.394-.789A2.002%202.002%200%200%200%2017.764%204h-5.528a2%202%200%200%200-1.789%201.106l-.394.789A2.002%202.002%200%200%201%208.264%207H4a2%202%200%200%200-2%202v13a2%202%200%200%200%202%202h22a2%202%200%200%200%202-2V9a2%202%200%200%200-2-2zM15%2022c-3.86%200-7-3.14-7-7s3.14-7%207-7%207%203.14%207%207-3.14%207-7%207zm9-11a1%201%200%201%201%200-2%201%201%200%200%201%200%202z'/%3E%3C/svg%3E">

				<DIV>
					Photo
				</DIV>
			</DIV>

			<DIV class="dash_button">
				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20height='1792'%20viewBox='0%200%201792%201792'%20width='1792'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23ffffff'%20d='M832%20320v704q0%20104-40.5%20198.5t-109.5%20163.5-163.5%20109.5-198.5%2040.5h-64q-26%200-45-19t-19-45v-128q0-26%2019-45t45-19h64q106%200%20181-75t75-181v-32q0-40-28-68t-68-28h-224q-80%200-136-56t-56-136v-384q0-80%2056-136t136-56h384q80%200%20136%2056t56%20136zm896%200v704q0%20104-40.5%20198.5t-109.5%20163.5-163.5%20109.5-198.5%2040.5h-64q-26%200-45-19t-19-45v-128q0-26%2019-45t45-19h64q106%200%20181-75t75-181v-32q0-40-28-68t-68-28h-224q-80%200-136-56t-56-136v-384q0-80%2056-136t136-56h384q80%200%20136%2056t56%20136z'/%3E%3C/svg%3E">

				<DIV>
					Quote
				</DIV>
			</DIV>

			<DIV class="dash_button">
				<IMG style="height: 60%; margin-top: 4%; margin-bottom: 4px;"
				     src="data:image/svg+xml;charset=utf8,%3Csvg%20height='80'%20width='80'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23fff'%20d='M29.298%2063.471l-4.048%204.02c-3.509%203.478-9.216%203.481-12.723%200-1.686-1.673-2.612-3.895-2.612-6.257s.927-4.585%202.611-6.258l14.9-14.783c3.088-3.062%208.897-7.571%2013.131-3.372a4.956%204.956%200%201%200%206.985-7.034c-7.197-7.142-17.834-5.822-27.098%203.37L5.543%2047.941C1.968%2051.49%200%2056.21%200%2061.234s1.968%209.743%205.544%2013.292C9.223%2078.176%2014.054%2080%2018.887%2080c4.834%200%209.667-1.824%2013.348-5.476l4.051-4.021a4.955%204.955%200%200%200%20.023-7.009%204.96%204.96%200%200%200-7.011-.023zM74.454%206.044c-7.73-7.67-18.538-8.086-25.694-.986l-5.046%205.009a4.958%204.958%200%200%200%206.986%207.034l5.044-5.006c3.707-3.681%208.561-2.155%2011.727.986a8.752%208.752%200%200%201%202.615%206.258%208.763%208.763%200%200%201-2.613%206.259l-15.897%2015.77c-7.269%207.212-10.679%203.827-12.134%202.383a4.957%204.957%200%200%200-6.985%207.034c3.337%203.312%207.146%204.954%2011.139%204.954%204.889%200%2010.053-2.462%2014.963-7.337l15.897-15.77C78.03%2029.083%2080%2024.362%2080%2019.338c0-5.022-1.97-9.743-5.546-13.294z'/%3E%3C/svg%3E">

				<DIV>
					Link
				</DIV>
			</DIV>

			<DIV class="dash_button">
				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20height='500'%20width='500'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20clip-rule='evenodd'%20d='M36.992%20326.039c0%2020.079%2016.262%2036.34%2036.34%2036.34h54.513v56.062c0%2010.087%208.181%2018.168%2018.172%2018.168%205.092%200%209.714-2.095%2012.989-5.448l68.78-68.781h199.881c20.078%200%2036.34-16.261%2036.34-36.34V98.902c0-20.079-16.262-36.341-36.34-36.341H73.333c-20.079%200-36.34%2016.262-36.34%2036.341v227.137zm109.026-104.482c0-12.536%2010.177-22.713%2022.713-22.713%2012.536%200%2022.713%2010.177%2022.713%2022.713%200%2012.537-10.177%2022.713-22.713%2022.713-12.537%200-22.713-10.177-22.713-22.713zm81.769%200c0-12.536%2010.177-22.713%2022.713-22.713%2012.537%200%2022.715%2010.177%2022.715%2022.713%200%2012.537-10.178%2022.713-22.715%2022.713-12.536%200-22.713-10.177-22.713-22.713zm81.769%200c0-12.536%2010.176-22.713%2022.715-22.713%2012.537%200%2022.711%2010.177%2022.711%2022.713%200%2012.537-10.174%2022.713-22.711%2022.713-12.54%200-22.715-10.177-22.715-22.713z'%20fill='%23FFF'%20fill-rule='evenodd'/%3E%3C/svg%3E">

				<DIV>
					Chat
				</DIV>
			</DIV>

			<DIV class="dash_button">
				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20width='96'%20height='96'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='none'%20d='M-1-1h582v402H-1z'/%3E%3Cg%3E%3Cpath%20fill='%23fff'%20d='M71.8%2043.5L30.6%2021.8c-1.9-1-4.2-.9-6%20.2-1.6%201-2.6%202.7-2.6%204.5v41.3c0%201.8%201%203.5%202.6%204.5%201%20.6%202.1.9%203.2.9%201%200%202-.2%202.8-.7l41.2-21.7c1.3-.7%202.2-2.1%202.2-3.6%200-1.6-.8-3-2.2-3.7z'/%3E%3C/g%3E%3C/svg%3E">

				<DIV>
					Audio
				</DIV>
			</DIV>

			<DIV class="dash_button">
				<IMG style="width: 500px;"
				     src="data:image/svg+xml;charset=utf8,%3Csvg%20width='24'%20height='24'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='none'%20d='M-1-1h582v402H-1z'/%3E%3Cg%3E%3Cpath%20fill='%23fff'%20d='M22.525%207.149C22.365%207.05%2022.183%207%2022%207c-.153%200-.306.035-.447.105L19%208.382V8c0-1.654-1.346-3-3-3H5C3.346%205%202%206.346%202%208v8c0%201.654%201.346%203%203%203h11c1.654%200%203-1.346%203-3v-.382l2.553%201.276c.141.071.294.106.447.106.183%200%20.365-.05.525-.149.295-.183.475-.504.475-.851V8c0-.347-.18-.668-.475-.851zM7%2013.5c-.829%200-1.5-.671-1.5-1.5s.671-1.5%201.5-1.5%201.5.671%201.5%201.5-.671%201.5-1.5%201.5z'/%3E%3C/g%3E%3C/svg%3E">

				<DIV>
					Video
				</DIV>
			</DIV>
		</DIV>

		<DIV class="dash_settings">
			<DIV class="dash_settings_nav">
				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20height='32'%20width='32'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23aea8d3'%20d='M16%200l16%2016h-4v14h-8V20h-8v10H4V16H0z'/%3E%3C/svg%3E">

				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20height='512'%20width='512'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23aea8d3'%20d='M256%2048C141.1%2048%2048%20141.1%2048%20256s93.1%20208%20208%20208%20208-93.1%20208-208S370.9%2048%20256%2048zm0%20336V256H128.3L352%20160l-96%20224z'/%3E%3C/svg%3E">

				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20viewBox='0%200%2030%2030'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23aea8d3'%20d='M16.189%2016.521L27.463%206H2.537L13.81%2016.521c.667.624%201.713.624%202.379%200zM8.906%2014.68L1%207.301v15.285zM21.094%2014.68L29%2022.586V7.301z'/%3E%3Cpath%20fill='%23aea8d3'%20d='M19.631%2016.045l-2.077%201.938c-.717.669-1.636%201.003-2.555%201.003s-1.838-.334-2.555-1.003l-2.077-1.938L2.414%2024h25.172l-7.955-7.955z'/%3E%3C/svg%3E">

				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20height='48'%20width='48'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23aea8d3'%20d='M40%204H8C5.79%204%204.02%205.79%204.02%208L4%2044l8-8h28c2.21%200%204-1.79%204-4V8c0-2.21-1.79-4-4-4zm-4%2024H12v-4h24v4zm0-6H12v-4h24v4zm0-6H12v-4h24v4z'/%3E%3Cpath%20d='M0%200h48v48H0z'%20fill='none'/%3E%3C/svg%3E">

				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20height='512'%20width='512'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cpath%20fill='%23aea8d3'%20d='M302.7%2064L143%20288h95.8l-29.5%20160L369%20224h-95.8l29.5-160z'/%3E%3C/svg%3E">

				<IMG src="data:image/svg+xml;charset=utf8,%3Csvg%20height='32'%20width='32'%20xmlns='http://www.w3.org/2000/svg'%3E%3Cg%20fill='%23aea8d3'%3E%3Cpath%20d='M22.417%2014.836c-1.209%202.763-3.846%205.074-6.403%205.074-3.122%200-5.39-2.284-6.599-5.046C2.384%2018.506%203.27%2027.723%203.27%2027.723c0%201.262.994%201.445%202.162%201.445h21.146c1.17%200%202.167-.184%202.167-1.445.001%200%20.702-9.244-6.328-12.887z'/%3E%3Cpath%20d='M16.013%2018.412c3.521%200%206.32-5.04%206.32-9.204%200-4.165-2.854-7.541-6.375-7.541S9.582%205.043%209.582%209.208c0%204.165%202.909%209.204%206.431%209.204z'/%3E%3C/g%3E%3C/svg%3E">
			</DIV>

			<INPUT type="text" placeholder="Search…" onkeydown="handleSearch(this)" />

			<DIV id="search_results">
			</DIV>
		</DIV>

		<DIV class="dash_main">
			<H1>
				auth#password
			</H1>

			<P>
				Rendered from app/views/auth/password.html.tpl.
			</P>
		</DIV>
	</BODY>
</HTML>
