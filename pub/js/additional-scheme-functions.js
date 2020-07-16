BiwaScheme.define_libfunc("http-get-async",
                          1,
                          4,
                          function(args, intp) {
                          	BiwaScheme.assert_string(args[0]);

                          	switch(args.length) {
                          		case(1):
                          			$.get(args[0]);

                          			break;
                          		case(2):
                          			if(BiwaScheme.CoreEnv["list?"]([args[1]])) {
                          				$.get(args[0],
                          				      BiwaScheme.CoreEnv["alist->js-obj"]([args[1]]));
                          			} else if(args[1]        !== null     &&
                          			          typeof args[1] === "object" &&
                          			          !(args[1] instanceof Array)) {
                          				$.get(args[0], args[1]);
                          			} else if(typeof args[1] === "string") {
                          				$.get(args[0], args[1]);
                          			} else {
                          				$.get(args[0],
                          				      function(data) {
                          				      	intp.invoke_closure(args[1], [data]);
                          				      });
                          			}

                          			break;
                          		case(3):
                          			if(BiwaScheme.CoreEnv["list?"]([args[1]])) {
                          				if(typeof args[2] === "string") {
                          					$.get(args[0],
                          					      BiwaScheme.CoreEnv["alist->js-obj"]([args[1]]),
                          					      args[2]);
                          				} else {
                          					$.get(args[0],
                          					      BiwaScheme.CoreEnv["alist->js-obj"]([args[1]]),
                          					      function(data) {
                          					      	intp.invoke_closure(args[2], [data]);
                          					      });
                          				}
                          			} else if(args[1]        !== null     &&
                          			          typeof args[1] === "object" &&
                          			          !(args[1] instanceof Array)) {
                          				if(typeof args[2] === "string") {
                          					$.get(args[0], args[1], args[2]);
                          				} else {
                          					$.get(args[0],
                          					      args[1],
                          					      function(data) {
                          					      	intp.invoke_closure(args[2], [data]);
                          					      });
                          				}
                          			} else {
                          				BiwaScheme.assert_string(args[2]);

                          				$.get(args[0],
                          				      function(data) {
                          				      	intp.invoke_closure(args[1], [data]);
                          				      },
                          				      args[2]);
                          			}

                          			break;
                          		case(4):
                          			BiwaScheme.assert_string(args[3]);

                          			if(BiwaScheme.CoreEnv["list?"]([args[1]])) {
                          				$.get(args[0],
                          				      BiwaScheme.CoreEnv["alist->js-obj"]([args[1]]),
                          				      function(data) {
                          				      	intp.invoke_closure(args[2], [data]);
                          				      },
                          				      args[3]);
                          			} else {
                          				$.get(args[0],
                          				      args[1],
                          				      function(data) {
                          				      	intp.invoke_closure(args[2], [data]);
                          				      },
                          				      args[3]);
                          			}

                          			break;
                          	}
                          });

BiwaScheme.define_libfunc("string->js-obj", 1, 1, function(args) {
                                                  	BiwaScheme.assert_string(args[0]);

                                                  	return JSON.parse(args[0]);
                                                  });

BiwaScheme.define_libfunc("string-contains-last",
                          2,
                          2,
                          function(args) {
                          	BiwaScheme.assert_string(args[0]);
                          	BiwaScheme.assert_string(args[1]);

                          	var result = args[0].lastIndexOf(args[1]);

                          	if(result === -1) {
                          		return false;
                          	} else {
                          		return result;
                          	}
                          });
